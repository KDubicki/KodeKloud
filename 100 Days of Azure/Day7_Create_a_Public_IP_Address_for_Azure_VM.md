# Day 7 - Create a Public IP Address for Azure VM

## Objective
As part of the ongoing, incremental migration strategy to the Azure cloud, the Nautilus DevOps team requires external connectivity for future infrastructure components. The objective of this specific task is to provision and allocate a standalone Public IP Address resource named `nautilus-pip`, which can later be attached to a Virtual Machine or Load Balancer.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Resource Name:** `nautilus-pip`

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically. This programmatic approach ensures the resource is deployed within the correct, validated laboratory boundaries without relying on hardcoded values.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 2. Allocate the Public IP Address
Executed the deployment utilizing the `az network public-ip create` command. This creates a standalone Public IP resource within the specified resource group.

    az network public-ip create \
      --resource-group $RG_NAME \
      --name nautilus-pip

### 3. Verification
Confirmed the successful deployment via the returned JSON payload. The state was verified by observing the provisioning state and the assigned IP address properties:

    # Expected Indicators in JSON Output:
    # "provisioningState": "Succeeded"
    # The output will also include the newly allocated public IP address details.