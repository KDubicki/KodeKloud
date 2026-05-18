# Day 2 - Create an Azure Virtual Machine

## Objective
The Nautilus DevOps team is migrating infrastructure to Azure in incremental steps. As part of this transition, the objective is to provision an Azure Virtual Machine (VM) configured with specific operational parameters, including target region, compute size, storage tier, and secure network access.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **VM Name:** `devops-vm`
* **Region:** `westus`
* **OS Image:** Ubuntu 24.04 LTS
* **Instance Size:** `Standard_B1s`
* **Storage:** 30 GB, Standard HDD (`Standard_LRS`)
* **Network Security:** Default NSG with inbound SSH (Port 22) allowed

> **Security Note:** Sensitive credentials and specific lab subscription parameters have been redacted from this documentation to maintain security best practices in public repositories.

---

## Execution Steps

### 1. Authenticate with Azure CLI
Utilized the secure Device Code authentication flow to bypass potential shell interpretation issues with special characters in temporary lab passwords.

    az login --use-device-code

### 2. Dynamically Identify the Target Resource Group
Retrieved the pre-assigned target Resource Group programmatically to ensure the VM is deployed exactly where the laboratory validation scripts expect it.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 3. Provision the Virtual Machine
Executed the deployment using the `az vm create` command. The CLI automatically handles the creation of the Virtual Network (VNet), Subnet, Public IP, and Network Security Group (NSG) with SSH allowed by default when deploying a Linux image. The `--generate-ssh-keys` flag ensures cryptographic access is established.

    az vm create \
      --resource-group $RG_NAME \
      --name devops-vm \
      --location westus \
      --image Ubuntu2404 \
      --size Standard_B1s \
      --os-disk-size-gb 30 \
      --storage-sku Standard_LRS \
      --generate-ssh-keys

### 4. Verify SSH Connectivity
Extracted the allocated `publicIpAddress` from the deployment JSON output and successfully established an SSH connection to validate the inbound Port 22 NSG rule and key authentication.

    ssh azureuser@<public-ip-address>
    # Connection successfully established.