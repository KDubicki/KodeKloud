# Day 6 - Create a Subnet in Azure Virtual Network

## Objective
The Nautilus DevOps team is continuing its phased migration to the Azure cloud. As the infrastructure grows, network segmentation becomes critical. The objective of this task is to provision a Virtual Network (VNet) along with an initial, explicitly defined Subnet to house future workloads securely.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Region:** `centralus`
* **VNet Name:** `nautilus-vnet`
* **VNet CIDR:** `10.0.0.0/16`
* **Subnet Name:** `nautilus-subnet`
* **Subnet CIDR:** `10.0.0.0/24`

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically. This programmatic approach ensures the resources are deployed within the correct, validated laboratory boundaries.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 2. Provision the Virtual Network and Subnet
Executed the deployment utilizing the `az network vnet create` command. Azure CLI allows for the simultaneous creation of a VNet and an associated Subnet by supplying the respective subnet arguments, streamlining the deployment process.

    az network vnet create \
      --resource-group $RG_NAME \
      --name nautilus-vnet \
      --location centralus \
      --address-prefixes 10.0.0.0/16 \
      --subnet-name nautilus-subnet \
      --subnet-prefixes 10.0.0.0/24

### 3. Verification
Confirmed the successful deployment via the returned JSON payload. The state was verified by observing the state properties for both the virtual network and its nested subnet structure:

    # Expected State Indicator in JSON:
    # "provisioningState": "Succeeded"