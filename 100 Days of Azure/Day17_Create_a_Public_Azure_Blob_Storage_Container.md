# Task: Day 17 - Create a Public Azure Blob Storage Container

## Objective
As the Nautilus DevOps team advances their data migration strategy, specific datasets require public availability (e.g., publicly accessible web assets, open-source documentation). The objective of this task is to provision a new Azure Storage Account and establish a Blob container with anonymous read access configured at both the container and blob levels.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Storage Account Name:** `datacenterst24399`
* **Blob Container Name:** `datacenter-blob-8942`
* **Account Level Security:** `allow-blob-public-access` set to `true`
* **Container Access Level:** `container` (Anonymous read access for containers and blobs)

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group and Location
Extracted the pre-provisioned resource group and its region dynamically to ensure the targeted deployment remains within the authorized laboratory scope.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    LOCATION=$(az group show --name $RG_NAME --query location -o tsv)

### 2. Provision the Storage Account with Public Access Enabled
Executed the storage account creation utilizing the `az storage account create` command. Due to modern Azure security defaults (Secure by Default), the `--allow-blob-public-access true` flag was explicitly passed to override the default lock and permit public access configuration at the container level.

    az storage account create \
      --name datacenterst24399 \
      --resource-group $RG_NAME \
      --location $LOCATION \
      --sku Standard_LRS \
      --allow-blob-public-access true

### 3. Provision the Public Blob Container
Created the Blob container specifically within the newly provisioned Storage Account. The `--public-access` flag was set to `container`, granting anonymous read access to the container and all blobs nested within it, fulfilling the task requirement.

    az storage container create \
      --account-name datacenterst24399 \
      --name datacenter-blob-8942 \
      --public-access container

### 4. Verification
Confirmed the successful deployment and access assignment via the JSON payload returned by the container creation command.

    # Expected JSON Output:
    # {
    #   "created": true
    # }