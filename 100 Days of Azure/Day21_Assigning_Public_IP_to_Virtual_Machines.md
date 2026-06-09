# Day 21 - Assigning Public IP to Virtual Machines

## Objective
The Development Team requires a new compute instance with a stable, consistent entry point to host a new application. The objective of this task is to provision an Azure Virtual Machine configured with a Static Public IP address. Additionally, secure passwordless authentication must be established by generating and associating a new SSH public key from the deployment host.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Region:** `centralus`
* **VM Name:** `datacenter-vm`
* **Image:** Ubuntu 22.04 LTS
* **Size:** `Standard_B1s`
* **OS Disk SKU:** `Standard_LRS` (Enforced by Azure Policy)
* **Public IP Name:** `datacenter-pip`
* **IP Allocation Method:** `Static`

---

## Execution Steps

### 1. Dynamically Resolve the Target Resource Group
Programmatically extracted the pre-provisioned resource group to ensure the infrastructure is deployed within the correct laboratory boundaries.

    RG_NAME=$(az group list --query "[0].name" -o tsv)

### 2. Provision the Static Public IP Address
Created a standalone Public IP (PIP) resource configured with a `Static` allocation method and `Standard` SKU.

    az network public-ip create \
      --resource-group $RG_NAME \
      --name datacenter-pip \
      --location centralus \
      --sku Standard \
      --allocation-method Static

### 3. Clear Corrupted State (If Applicable)
If previous deployment attempts failed due to strict Azure Policies (see Troubleshooting), purge the ghost resource explicitly utilizing the Azure Resource Manager (ARM) API.

    VM_ID=$(az vm show --resource-group $RG_NAME --name datacenter-vm --query id -o tsv)
    az resource delete --ids $VM_ID

### 4. Provision the Virtual Machine & Generate SSH Keys
Executed the compute deployment utilizing the `az vm create` command. The previously created static IP was attached to the network interface. The `--generate-ssh-keys` flag was utilized to establish passwordless authentication. The `--storage-sku` flag was explicitly declared to comply with strict cost-management governance rules.

    az vm create \
      --resource-group $RG_NAME \
      --name datacenter-vm \
      --location centralus \
      --image Ubuntu2204 \
      --size Standard_B1s \
      --admin-username azureuser \
      --public-ip-address datacenter-pip \
      --storage-sku Standard_LRS \
      --generate-ssh-keys

### 5. Verification
Confirmed the operational status and security configuration by fetching the assigned static IP and establishing a secure SSH tunnel.

    VM_IP=$(az network public-ip show \
      --resource-group $RG_NAME \
      --name datacenter-pip \
      --query ipAddress \
      --output tsv)
    
    ssh -o StrictHostKeyChecking=no azureuser@$VM_IP
    # Expected Output: Successful login shell prompt for datacenter-vm.
    exit

---

## Troubleshooting Summary: The "Ghost Resource" Deadlock
This deployment required advanced troubleshooting due to conflicting Azure state management and aggressive Azure Policy enforcement.

* **Phase 1 (Policy Enforcement):** The initial `az vm create` deployment failed with a `RequestDisallowedByPolicy` exception blocking the default `Premium_LRS` OS disk allocation.
* **Phase 2 (Locked Resource State):** Re-running the deployment with `--storage-sku Standard_LRS` resulted in a `PropertyChangeNotAllowed` error because Azure had already provisioned a partially complete "ghost" VM.
* **Phase 3 (Cascading Delete Failure):** Attempting to run `az vm delete` triggered another `RequestDisallowedByPolicy` error. The deletion process validates the disk state, which the policy blocked because the ghost VM was still tied to a Premium disk definition.
* **Phase 4 (Non-Existent Disk):** Attempting to update the orphaned disk via `az disk update` failed because the disk was never physically created—resulting in an empty query and a missing argument error. 
* **Resolution (ARM API Purge):** Broke the policy deadlock by bypassing high-level compute commands. Extracted the raw ARM Resource ID (`VM_ID`) and utilized `az resource delete --ids $VM_ID`. This low-level command forcefully purged the logical VM state without triggering the standard disk policy checks, clearing the namespace for a successful deployment with the `Standard_LRS` flag.