# Day 19 - Convert Public Azure Blob Container to Private

## Objective
The Nautilus DevOps team is auditing data security policies across the newly migrated Azure infrastructure. An existing blob container was identified as having overly permissive public access. The objective of this task is to remediate this security risk by converting the container (`xfusion-container-4017`) from public to private (no public access), without disrupting other isolated containers within the same storage account.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Target Storage Account:** `xfusionst19298`
* **Target Blob Container:** `xfusion-container-4017`
* **Required Access Level:** Private (`off` / No public read access)

---

## Execution Steps

### 1. Dynamically Retrieve Storage Account Key
Extracted the primary storage account access key to securely authenticate the permission modification command and bypass potential Azure RBAC propagation delays.

    ACCOUNT_KEY=$(az storage account keys list \
      --account-name xfusionst19298 \
      --query "[0].value" \
      --output tsv)

### 2. Revoke Public Access
Executed the permission update utilizing the `az storage container set-permission` command. The `--public-access` argument was explicitly set to `off`, completely restricting anonymous read access for both the container and its nested blobs.

    az storage container set-permission \
      --name xfusion-container-4017 \
      --account-name xfusionst19298 \
      --public-access off \
      --account-key $ACCOUNT_KEY

### 3. Verification
Confirmed the successful remediation by querying the container's access level properties.

    az storage container show \
      --name xfusion-container-4017 \
      --account-name xfusionst19298 \
      --account-key $ACCOUNT_KEY \
      --query "publicAccess" \
      --output tsv
    
    # Expected Output: None / Null (indicating no public access is configured)