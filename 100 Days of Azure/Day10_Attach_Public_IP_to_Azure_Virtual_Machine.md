# Day 10 - Attach Public IP to Azure Virtual Machine

## Objective
The Nautilus DevOps team requires external connectivity for a recently deployed Virtual Machine. In Azure Resource Manager (ARM) architecture, Public IPs are not bound directly to the VM compute resource, but rather to the IP Configuration of the underlying Network Interface Card (NIC). The objective is to attach an existing Public IP (`xfusion-pip`) to the primary NIC of the VM (`xfusion-vm-pip`).

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Target VM Name:** `xfusion-vm-pip`
* **Public IP Name:** `xfusion-pip`

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically to ensure actions are scoped to the correct active laboratory environment.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 2. Identify the Attached Network Interface (NIC)
Programmatically queried the VM's network profile to extract the underlying Network Interface Card (NIC) ID, and parsed it to isolate the NIC resource name.

    NIC_ID=$(az vm show \
      --resource-group $RG_NAME \
      --name xfusion-vm-pip \
      --query "networkProfile.networkInterfaces[0].id" \
      --output tsv)
    
    NIC_NAME=${NIC_ID##*/}
    echo "Resolved NIC Name: $NIC_NAME"

### 3. Identify the Target IP Configuration
Queried the identified NIC to extract the name of its primary IP configuration rule (typically `ipconfig1`), which acts as the attachment point for the Public IP.

    IP_CONFIG=$(az network nic show \
      --resource-group $RG_NAME \
      --name $NIC_NAME \
      --query "ipConfigurations[0].name" \
      --output tsv)
    
    echo "Resolved IP Configuration: $IP_CONFIG"

### 4. Attach the Public IP Address
Executed the network configuration update utilizing the `az network nic ip-config update` command. This successfully linked the standalone Public IP resource to the VM's network interface.

    az network nic ip-config update \
      --resource-group $RG_NAME \
      --nic-name $NIC_NAME \
      --name $IP_CONFIG \
      --public-ip-address xfusion-pip

### 5. Verification
Confirmed the successful attachment by inspecting the returned JSON payload. The state was verified by observing that the `publicIPAddress` object was successfully populated within the `ipConfigurations` array.