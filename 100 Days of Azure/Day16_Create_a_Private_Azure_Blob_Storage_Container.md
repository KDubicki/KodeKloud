# Task: Day 16 - Create a Private Azure Blob Storage Container

## Objective
The Nautilus DevOps team is expanding its Azure cloud footprint by incorporating data storage solutions into the migration strategy. Centralizing data alongside compute resources minimizes latency and operational overhead. The objective of this task is to provision an Azure Storage Account and establish a private Blob container to securely house unstructured data.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Storage Account Name:** `devopsst27370`
* **Storage SKU:** `Standard_LRS`
* **Blob Container Name:** `devops-blob-16126`
* **Access Level:** Private (No public read access)

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group and Location
Fetched the pre-provisioned resource group dynamically. Extracted the group's location to ensure the storage account is deployed in the same region, optimizing future intra-service data transfer.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    LOCATION=$(az group show --name $RG_NAME --query location -o tsv)

### 2. Provision the Storage Account
Executed the deployment utilizing the `az storage account create` command. The `Standard_LRS` SKU provides cost-effective, locally redundant storage suitable for standard migration workloads.

    az storage account create \
      --name devopsst27370 \
      --resource-group $RG_NAME \
      --location $LOCATION \
      --sku Standard_LRS

### 3. Provision the Private Blob Container
Created the Blob container specifically within the newly provisioned Storage Account. By design, Azure Blob containers are private by default, securing the data from unauthorized public access immediately upon creation.

    az storage container create \
      --account-name devopsst27370 \
      --name devops-blob-16126

### 4. Verification
Confirmed the successful deployment via the JSON payload returned by the container creation command.

    # Expected JSON Output:
    # {
    #   "created": true
    # }