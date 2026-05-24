# Day 14 - Create Managed Disks in Azure

## Objective
The Nautilus DevOps team is continuing their incremental migration strategy to the Azure cloud. As part of decoupling compute from storage for better risk mitigation and resource optimization, the objective of this task is to provision a standalone Managed Disk. This disk can later be attached to any virtual machine within the same region.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Disk Name:** `xfusion-disk`
* **Disk Type (SKU):** `Standard_LRS` (Standard HDD, Locally Redundant Storage)
* **Disk Size:** 2 GiB

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group and Location
Fetched the pre-provisioned resource group dynamically. Additionally, the location of the resource group was extracted to ensure the newly provisioned disk resides in the exact same region as the future compute resources it will be attached to.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    LOCATION=$(az group show --name $RG_NAME --query location -o tsv)
    
    echo "Target Resource Group: $RG_NAME"
    echo "Target Location: $LOCATION"

### 2. Provision the Managed Disk
Executed the resource creation utilizing the `az disk create` command. The command specifies the exact SKU and size requirements defined by the migration plan.

    az disk create \
      --resource-group $RG_NAME \
      --name xfusion-disk \
      --size-gb 2 \
      --sku Standard_LRS \
      --location $LOCATION

### 3. Verification
Confirmed the successful deployment via the returned JSON payload. Verified the `provisioningState` property to ensure the disk is fully allocated and ready for use.

    # Expected State Indicator in JSON Output:
    # "provisioningState": "Succeeded"
    # "diskSizeGB": 2