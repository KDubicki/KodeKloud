# Day 12 - Add and Manage Tags for Azure Virtual Machines

## Objective
As part of the Azure infrastructure migration and implementation of Cloud Governance best practices, the Nautilus DevOps team requires strict resource categorization. The objective of this task is to ensure proper resource tracking by appending a specific metadata tag (`Environment=dev`) to an existing Virtual Machine (`xfusion-vm`) without disrupting its current operational state or overwriting existing tags.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Target VM Name:** `xfusion-vm`
* **Tag Key:** `Environment`
* **Tag Value:** `dev`

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically to ensure the CLI strictly targets the correct active laboratory deployment.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 2. Append the Tag to the Virtual Machine
Executed the resource modification utilizing the `az vm update` command. By using the `--set` property argument, the new tag key-value pair is safely merged into the VM's metadata array without wiping out any potentially existing tags.

    az vm update \
      --resource-group $RG_NAME \
      --name xfusion-vm \
      --set tags.Environment=dev

### 3. Verification
Confirmed the successful tagging operation by querying the specific metadata attribute of the virtual machine.

    az vm show \
      --resource-group $RG_NAME \
      --name xfusion-vm \
      --query "tags" \
      --output json
    
    # Expected JSON Output:
    # {
    #   "Environment": "dev"
    # }