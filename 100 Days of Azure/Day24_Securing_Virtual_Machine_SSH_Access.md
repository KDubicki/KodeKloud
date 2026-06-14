# Day 24 - Securing Virtual Machine SSH Access

## Objective
The Nautilus DevOps team requires a secure, automated provisioning process for new compute resources within the Azure cloud. The objective of this task is to deploy a new Virtual Machine (`datacenter-vm`) and establish a secure, password-less SSH trust from the designated landing host (`azure-client`). This ensures administrative access is strictly governed by cryptographic keys rather than vulnerable password-based authentication.

During deployment, strict Azure Policy constraints regarding resource costs (Premium Storage blocks) must be bypassed using specific SKU declarations.

## Architecture & Environment Details

* **Cloud Provider:** Microsoft Azure
* **Deployment Tool:** Azure CLI (executed from `azure-client` host)
* **Target Region:** `westus`
* **Virtual Machine Name:** `datacenter-vm`
* **Instance Size:** `Standard_B1s`
* **Storage SKU:** `Standard_LRS` (Enforced by Azure Policy)
* **Admin Username:** `azureuser`
* **Authentication Mechanism:** `RSA 4096-bit SSH Key Pair`


## Execution Steps

### 1. Check and Generate SSH Key Pair

Verified the existence of an RSA key pair on the azure-client host. If absent, a new 4096-bit RSA key pair was dynamically generated. By performing this locally rather than relying on Azure API generation, we ensured the private key never leaves the client machine, adhering to strict zero-trust principles.

```bash
[ ! -f ~/.ssh/id_rsa ] && ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### 2. Dynamically Resolve the Resource Group

Programmatically extracted the pre-provisioned lab Resource Group to prevent hardcoding values and maintain compatibility with automated validation scripts.

```bash
RG=$(az group list --query "[0].name" -o tsv)
```

### 3. Handle Failed Provisioning States (Ghost Resources)

Note: If an initial deployment fails due to Policy constraints, Azure may leave a "failed" virtual machine object without disks. To ensure a clean deployment state and bypass policy deadlocks during deletion, a forced cleanup of any existing failed VM object was executed.

```bash
VM_ID=$(az vm show --resource-group $RG --name datacenter-vm --query id -o tsv 2>/dev/null)
if [ -n "$VM_ID" ]; then 
  az vm delete --resource-group $RG --name datacenter-vm --force-deletion true --yes
fi
```

### 4. Provision the Virtual Machine

Executed the core compute deployment command. The `az vm create` command automatically handles the creation of the underlying Virtual Network (VNet), Subnet, Public IP, and Network Security Group (NSG) with an inbound rule for Port 22.

Crucially, the `--storage-sku Standard_LRS` flag was appended to comply with the organization's Azure Policy restricting Premium compute disks.

```bash
az vm create \
  --resource-group $RG \
  --name datacenter-vm \
  --location westus \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --size Standard_B1s \
  --ssh-key-values ~/.ssh/id_rsa.pub \
  --storage-sku Standard_LRS
```

## Verification

To validate the deployment and the security configuration, the dynamically assigned Public IP was extracted, and an SSH session was established. The -o StrictHostKeyChecking=no flag was used to bypass the interactive fingerprint prompt during the automated test.

```bash
VM_IP=$(az vm show --resource-group $RG --name datacenter-vm --show-details --query publicIps -o tsv)
ssh -o StrictHostKeyChecking=no azureuser@$VM_IP
```

### Troubleshooting Summary / Edge Cases

Azure Policy Restriction (RequestDisallowedByPolicy): The default behavior of az vm create provisions an OS disk in the Premium tier (Premium_LRS). This violated an active policy.
Resolution: Appended --storage-sku Standard_LRS to explicitly downgrade the disk tier.
Deadlocked Deletions: Attempting to standard-delete a failed VM triggers another policy evaluation on the non-existent OS disk, causing a loop.
Resolution: Used --force-deletion true to bypass standard graceful deletion checks and forcefully wipe the compute object from the ARM state.