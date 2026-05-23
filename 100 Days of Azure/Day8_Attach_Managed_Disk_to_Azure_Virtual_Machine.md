# Day 8 - Attach Managed Disk to Azure Virtual Machine

## Objective
The Nautilus xfusion team is executing a phased migration to the Azure cloud. This phase requires enhancing the storage capacity of an existing compute resource. The objective is to attach an existing standalone managed data disk (`xfusion-disk`) to a currently running Virtual Machine (`xfusion-vm`).

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Region:** `eastus`
* **Target VM Name:** `xfusion-vm`
* **Managed Disk Name:** `xfusion-disk`

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically. This programmatic approach ensures the operational context is strictly bound to the active laboratory environment.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 2. Attach the Managed Disk to the VM
Executed the disk attachment procedure utilizing the `az vm disk attach` command. This effectively links the decoupled, standalone managed storage block to the active compute instance as a Data Disk.

    az vm disk attach \
      --resource-group $RG_NAME \
      --vm-name xfusion-vm \
      --name xfusion-disk

### 3. Verification
Confirmed the successful attachment by querying the VM's storage profile. Ensured the state of the VM allowed for the attachment without requiring a hard reboot or deallocation.

    az vm show \
      --resource-group $RG_NAME \
      --name xfusion-vm \
      --query "storageProfile.dataDisks[].name" \
      --output tsv
    
    # Expected Output: xfusion-disk