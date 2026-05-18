# Day 1 - Create SSH Key Pair for Azure Virtual Machine

## Objective
The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the Azure cloud using an incremental approach. The first phase requires the establishment of secure, passwordless authentication for future cloud resources. The objective of this task is to provision a default RSA SSH key pair named `devops-kp` within the designated Azure Resource Group.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Key Pair Name:** `devops-kp`
* **Key Type:** RSA (Azure Default)

> **Security Note:** Sensitive credentials, including the specific lab username and password, have been intentionally redacted from this public documentation to comply with production security best practices regarding secrets management.

---

## Execution Steps

### 1. Authenticate with Azure CLI via Device Code Flow
To bypass potential shell interpretation issues caused by special characters in temporary passwords, the secure Device Code authentication flow was utilized. This approach is highly recommended for headless server environments.

    az login --use-device-code
    # Followed the on-screen prompts to authenticate via the browser.

### 2. Dynamically Identify the Target Resource Group
In automated or sandbox laboratory environments, it is best practice to programmatically fetch the active Resource Group scope rather than hardcoding values. This ensures alignment with backend validation tools.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 3. Provision the Cloud SSH Key Resource
Executed the creation command within the resolved Resource Group. The explicit `--type rsa` parameter was omitted to leverage the modern Azure CLI default behaviors, preventing arguments mismatch exceptions.

    az sshkey create \
      --name "devops-kp" \
      --resource-group $RG_NAME

---

## Troubleshooting Summary
* **Authentication Failure (AADSTS50126):** Occurred during standard command-line authentication due to special characters handling. Resolved by switching to `--use-device-code`.
* **Unrecognized Arguments (--type rsa):** The installed Azure CLI version deprecated this flag as RSA is the native default format. Resolved by removing the explicit type parameter.

## Verification
The environment successfully generated and returned the valid JSON structure containing the cryptographic parameters:
* `publicKey`
* `privateKey`
The resource status was fully confirmed by the Azure Resource Manager (ARM).