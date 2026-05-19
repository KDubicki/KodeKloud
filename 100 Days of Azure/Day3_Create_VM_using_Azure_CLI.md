# Day 3 - Create VM using Azure CLI

## Objective
The Nautilus DevOps team is migrating workloads to Azure. This phase requires the deployment of a new Virtual Machine (VM) exclusively using the Azure CLI, simulating a restricted environment where portal UI access is unavailable.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **VM Name:** `nautilus-vm`
* **OS Image:** Ubuntu 22.04 LTS (`Ubuntu2204`)
* **Instance Size:** `Standard_B2s`
* **Admin User:** `azureuser`
* **Storage:** 30 GB, Standard HDD (`Standard_LRS`)
* **Authentication:** Auto-generated SSH keys

> **Security Note:** Sensitive credentials, including specific lab passwords and subscription hashes, have been intentionally redacted from this documentation to comply with security best practices regarding secret management in public source control.

---

## Execution Steps

### 1. Authenticate with Azure CLI
Established an authenticated session natively using the standard command-line credentials. Because the active session token was preserved (or the temporary password did not contain conflicting shell special characters), the standard login parameters succeeded directly without requiring a browser-based Device Code flow.

    az login -u "[REDACTED_USERNAME]@azurefreekmlprod.onmicrosoft.com" -p '[REDACTED_PASSWORD]'

### 2. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically. This prevents hardcoding and ensures the VM is deployed within the correct laboratory boundaries.

    RG_NAME=$(az group list --query "[0].name" -o tsv)

### 3. Provision the Virtual Machine
Executed the core deployment command. The CLI automatically handles the underlying networking components (VNet, Subnet, Public IP) and ensures the VM transitions directly into a `running` state upon successful creation. The `--generate-ssh-keys` parameter fulfills the requirement for secure, passwordless access.

    az vm create \
      --resource-group $RG_NAME \
      --name nautilus-vm \
      --image Ubuntu2204 \
      --size Standard_B2s \
      --admin-username azureuser \
      --os-disk-size-gb 30 \
      --storage-sku Standard_LRS \
      --generate-ssh-keys

### 4. Verification
Confirmed the successful deployment via the returned JSON payload. A quick state check can also be run to verify the power state:

    az vm show \
      --resource-group $RG_NAME \
      --name nautilus-vm \
      --show-details \
      --query powerState \
      --output tsv

    # Expected Output: VM running