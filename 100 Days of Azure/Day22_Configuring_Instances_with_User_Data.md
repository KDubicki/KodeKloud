# Task: Day 22 - Configuring Instances with User Data

## Objective
The Nautilus DevOps team is provisioning the initial web server infrastructure for a critical application. To ensure reliable, reproducible, and automated deployments, the objective of this task is to bypass manual server configuration by utilizing User Data (`cloud-init`). The Virtual Machine (`nautilus-vm`) must automatically install and start the Nginx web server immediately upon boot, and its Network Security Group (NSG) must be configured to permit public HTTP traffic on port 80.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`), `cloud-init`
* **Target Region:** `eastus`
* **VM Name:** `nautilus-vm`
* **Image:** Ubuntu 22.04 LTS
* **Size:** `Standard_B1s` (Overriding default sizing due to capacity constraints)
* **OS Disk SKU:** `Standard_LRS` (Enforced by Azure Policy)
* **Allowed Port:** `80` (HTTP)

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group
Programmatically fetched the pre-provisioned resource group to ensure the infrastructure acts within the correct laboratory boundaries.

    RG_NAME=$(az group list --query "[0].name" -o tsv)

### 2. Generate the Cloud-Init Configuration Payload
Created a declarative `#cloud-config` YAML file on the local deployment host. This payload defines the desired end-state of the server (package upgrades, nginx installation, and daemon initialization) without requiring interactive SSH sessions.

    cat <<EOF > cloud-init.yaml
    #cloud-config
    package_upgrade: true
    packages:
      - nginx
    runcmd:
      - systemctl enable nginx
      - systemctl start nginx
    EOF

### 3. Clean Corrupted State (If Applicable)
If previous deployment attempts failed due to capacity or policy restrictions, purge the resulting "ghost" resource explicitly using the `--force-deletion` flag to bypass underlying disk-state checks.

    az vm delete \
      --resource-group $RG_NAME \
      --name nautilus-vm \
      --force-deletion true \
      --yes

### 4. Provision the Virtual Machine with Custom Data
Executed the compute deployment utilizing the `az vm create` command. Passed the bootstrap payload via the `--custom-data` argument. The `--size` and `--storage-sku` parameters were explicitly defined to bypass default behaviors that violate current subscription capacities and restrictive governance policies.

    az vm create \
      --resource-group $RG_NAME \
      --name nautilus-vm \
      --location eastus \
      --image Ubuntu2204 \
      --admin-username azureuser \
      --size Standard_B1s \
      --storage-sku Standard_LRS \
      --generate-ssh-keys \
      --custom-data cloud-init.yaml

### 5. Configure the Network Security Group (NSG)
Modified the automatically generated NSG to explicitly permit inbound HTTP traffic originating from the internet (`0.0.0.0/0`) by utilizing the `az vm open-port` command wrapper.

    az vm open-port \
      --resource-group $RG_NAME \
      --name nautilus-vm \
      --port 80 \
      --priority 100

### 6. Verification
Confirmed the operational status by extracting the assigned public IP and executing an HTTP `GET` request. 
*Note: A 60-120 second delay was necessary before verification to allow the asynchronous cloud-init daemon process to finish executing post-boot.*

    VM_IP=$(az vm show -d \
      --resource-group $RG_NAME \
      --name nautilus-vm \
      --query publicIps \
      --output tsv)
    
    curl http://$VM_IP
    # Expected Output: Raw HTML string containing "Welcome to nginx!"

---

## Troubleshooting Summary
* **Issue 1 (Azure Capacity Restrictions):** The initial deployment attempt failed with a `SkuNotAvailable` exception, citing capacity restrictions for the default `Standard_DS1_v2` SKU in the `eastus` location. Resolved by declaring `--size Standard_B1s`.
* **Issue 2 (Azure Policy Enforcement):** The secondary deployment failed with a `RequestDisallowedByPolicy` exception. The policy explicitly blocked the default `Premium_LRS` OS disk allocation.
* **Issue 3 (The "Ghost Resource" Deadlock):** Because the initial deployment created a partial state, subsequent attempts caused conflicts. Attempting to query the orphaned disk ID returned a null value because the underlying disk never successfully provisioned. Resolved by executing `az vm delete` with the `--force-deletion true` flag, which brutally purged the logical VM state without validating the non-existent disk.
* **Issue 4 (Asynchronous Execution):** Immediate curl requests to the public IP resulted in a `Connection refused` error. This is expected behavior; `az vm create` reports success when the compute instance is provisioned, but the `cloud-init` script requires an additional 1-3 minutes to download and start the Nginx daemon asynchronously.