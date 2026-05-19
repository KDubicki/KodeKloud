# Day 4 - Create a Virtual Network (VNet) in Azure

## Objective
The Nautilus DevOps team is continuing the incremental migration of their infrastructure to the Azure cloud. To support future compute resources and ensure secure, private communication within the cloud environment, the team requires the foundational setup of a Virtual Network (VNet). The objective is to provision a VNet named `nautilus-vnet` with an allocated IPv4 address space.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **VNet Name:** `nautilus-vnet`
* **Region:** `westus`
* **CIDR Block:** `10.0.0.0/16` (Standard private IPv4 space)

> **Security Note:** Sensitive credentials, including specific lab passwords and usernames, have been intentionally redacted from this documentation to comply with security best practices regarding secret management in public source control.

---

## Execution Steps

### 1. Authenticate with Azure CLI via Device Code Flow
Due to the presence of special characters (e.g., `$`) in the provided temporary lab password, standard command-line authentication was prone to variable expansion errors in the Linux shell. To ensure a secure and reliable authentication process, the Device Code flow was utilized.

    az login --use-device-code
    # Followed the on-screen prompts to authenticate securely via the browser.

### 2. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically. This prevents hardcoding and ensures the networking resource is deployed within the correct laboratory boundaries.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 3. Provision the Virtual Network (VNet)
Executed the deployment utilizing the `az network vnet create` command. The VNet was provisioned in the specified region with a standard `/16` IPv4 address block, providing a highly scalable foundation for future subnets and resources.

    az network vnet create \
      --resource-group $RG_NAME \
      --name nautilus-vnet \
      --location westus \
      --address-prefixes 10.0.0.0/16

### 4. Verification
Confirmed the successful deployment via the returned JSON payload. The state was verified by observing the `provisioningState` property within the output:

    # Expected State Indicator in JSON:
    # "provisioningState": "Succeeded"

---

## Troubleshooting Summary
* **Authentication Variable Expansion:** The initial password contained a `$` character, causing the Linux shell to interpret it as an environment variable during inline authentication. 
* **Resolution:** Switched the authentication strategy to `az login --use-device-code`, which completely decouples the password input from the Linux shell, ensuring successful login.