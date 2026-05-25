# Day 15 - Create and Configure Network Security Group (NSG) in Azure

## Objective
The Nautilus DevOps team is taking incremental steps to secure their Azure cloud infrastructure. The objective of this task is to establish a foundational layer of network security by provisioning a Network Security Group (NSG) and configuring specific inbound access rules. The NSG will act as a virtual firewall, explicitly permitting HTTP web traffic and SSH administrative access while implicitly denying all other unsolicited inbound traffic.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **NSG Name:** `xfusion-nsg`
* **Security Rules:**
  * **Rule 1:** `Allow-HTTP` (Port 80, TCP, Inbound, Source: `0.0.0.0/0`)
  * **Rule 2:** `Allow-SSH` (Port 22, TCP, Inbound, Source: `0.0.0.0/0`)

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically to ensure all security resources are deployed within the correct laboratory scope.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 2. Provision the Network Security Group (NSG)
Created the base NSG resource. By default, an empty NSG contains default rules that allow intra-VNet traffic and outbound internet access, but deny all inbound traffic from the internet.

    az network nsg create \
      --resource-group $RG_NAME \
      --name xfusion-nsg

### 3. Configure the HTTP Inbound Rule
Added a custom security rule to explicitly allow inbound HTTP traffic. A priority of `100` was assigned (lower numbers have higher priority). The source CIDR `0.0.0.0/0` ensures the service is accessible publicly.

    az network nsg rule create \
      --resource-group $RG_NAME \
      --nsg-name xfusion-nsg \
      --name Allow-HTTP \
      --protocol Tcp \
      --direction Inbound \
      --priority 100 \
      --source-address-prefix 0.0.0.0/0 \
      --source-port-range '*' \
      --destination-address-prefix '*' \
      --destination-port-range 80 \
      --access Allow

### 4. Configure the SSH Inbound Rule
Added a secondary custom security rule to allow secure shell (SSH) administrative access. A priority of `110` was assigned to avoid conflicts.

    az network nsg rule create \
      --resource-group $RG_NAME \
      --nsg-name xfusion-nsg \
      --name Allow-SSH \
      --protocol Tcp \
      --direction Inbound \
      --priority 110 \
      --source-address-prefix 0.0.0.0/0 \
      --source-port-range '*' \
      --destination-address-prefix '*' \
      --destination-port-range 22 \
      --access Allow

### 5. Verification
The successful application of the rules was confirmed via the returned JSON payloads. The NSG is now successfully provisioned and ready to be associated with a Virtual Network subnet or a specific Network Interface Card (NIC).