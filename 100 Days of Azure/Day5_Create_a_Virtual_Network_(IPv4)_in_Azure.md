# Day 5 - Create a Virtual Network (IPv4) in Azure

## Objective
The Nautilus DevOps team is executing a strategic, phased migration of their infrastructure to the Azure cloud. The initial phase involves establishing the underlying network architecture, specifically Virtual Networks (VNets), which will host various isolated services. The objective of this task is to provision a VNet named `nautilus-vnet` with a highly specific IPv4 CIDR block (`192.168.0.0/24`).

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **VNet Name:** `nautilus-vnet`
* **Region:** `westus`
* **CIDR Block:** `192.168.0.0/24` (Provides 256 IP addresses)

---

## Execution Steps

### 1. Authenticate with Azure CLI via Device Code Flow
The provided temporary lab password contained a `#` character. In standard Bash shells, this character denotes a comment, which truncates the inline password and causes authentication failures. To ensure a secure and reliable login without shell parsing issues, the Device Code flow was utilized.

    az login --use-device-code
    # Authenticated securely via the browser using the provided temporary credentials.

### 2. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically. This prevents hardcoding and ensures the networking resource is deployed strictly within the monitored laboratory boundaries.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 3. Provision the Virtual Network (VNet)
Executed the deployment utilizing the `az network vnet create` command. The VNet was provisioned in the specified region with the exact `/24` IPv4 address block required by the network topology design.

    az network vnet create \
      --resource-group $RG_NAME \
      --name nautilus-vnet \
      --location westus \
      --address-prefixes 192.168.0.0/24

### 4. Verification
Confirmed the successful deployment via the returned JSON payload. The state was verified by observing the `provisioningState` property within the output:

    # Expected State Indicator in JSON:
    # "provisioningState": "Succeeded"