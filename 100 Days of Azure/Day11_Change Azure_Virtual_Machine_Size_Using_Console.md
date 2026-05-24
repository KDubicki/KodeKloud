# Day 11 - Change Azure Virtual Machine Size Using Console

## Objective
The Nautilus DevOps team is optimizing their Azure infrastructure. A specific virtual machine (`devops-vm`) requires vertical scaling (scaling up) to handle increased workload demands and maintain optimal performance. The objective is to resize the compute instance from `Standard_B1s` to `Standard_B2s` and ensure it returns to an active, running state.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Target VM Name:** `devops-vm`
* **Original Size:** `Standard_B1s`
* **Target Size:** `Standard_B2s`

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically to ensure the CLI targets the correct sandbox environment.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 2. Resize the Virtual Machine
Executed the vertical scaling operation utilizing the `az vm resize` command. This updates the underlying hardware allocation (CPU/RAM) for the compute instance.

    az vm resize \
      --resource-group $RG_NAME \
      --name devops-vm \
      --size Standard_B2s

### 3. Ensure Running State
Enforced the required final state. Resizing a VM forces a reboot or deallocation depending on hardware cluster availability. The `start` command guarantees the instance fulfills the operational requirement of being in a running state post-modification.

    az vm start \
      --resource-group $RG_NAME \
      --name devops-vm

### 4. Verification
Confirmed the successful operation by querying the current size and power state of the VM.

    az vm show \
      --resource-group $RG_NAME \
      --name devops-vm \
      --query "{Size:hardwareProfile.vmSize, State:powerState}" \
      --output table
    
    # Expected Output:
    # Size          State
    # ------------  -----------
    # Standard_B2s  VM running