# Day 18 - Copy Data to an Azure Blob Storage Container

## Objective
The Nautilus DevOps team is actively executing data migrations from on-premise systems to Azure Blob Storage. The objective of this task is to securely transfer a specific local dataset (`/tmp/nautilus.txt`) to a pre-provisioned Azure Blob container (`nautilus-blob-8173`) residing within the `nautilusst26564` storage account.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Source File Path:** `/tmp/nautilus.txt`
* **Target Storage Account:** `nautilusst26564`
* **Target Blob Container:** `nautilus-blob-8173`
* **Target Blob Name:** `nautilus.txt`

---

## Execution Steps

### 1. Dynamically Retrieve Storage Account Key
To ensure absolute reliability during the automated upload process and to bypass potential RBAC propagation delays, the primary storage account access key was programmatically extracted and stored in a shell variable.

    ACCOUNT_KEY=$(az storage account keys list \
      --account-name nautilusst26564 \
      --query "[0].value" \
      --output tsv)

### 2. Upload the File to Blob Storage
Executed the data transfer utilizing the `az storage blob upload` command. The command was authenticated explicitly using the dynamically retrieved account key. 

    az storage blob upload \
      --account-name nautilusst26564 \
      --container-name nautilus-blob-8173 \
      --file /tmp/nautilus.txt \
      --name nautilus.txt \
      --account-key $ACCOUNT_KEY

### 3. Verification
Confirmed the successful data transfer by querying the target Blob container's contents. The presence of the file confirms the upload was successful and data integrity is maintained.

    az storage blob list \
      --account-name nautilusst26564 \
      --container-name nautilus-blob-8173 \
      --account-key $ACCOUNT_KEY \
      --query "[].name" \
      --output tsv
    
    # Expected Output: nautilus.txt