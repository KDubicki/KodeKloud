# Day 20 - Deploy Azure Resources Using ARM Template

## Objective
The Nautilus DevOps team is transitioning towards Infrastructure as Code (IaC) to ensure consistent, repeatable, and version-controlled infrastructure deployments. The objective of this task is to modify a pre-existing Azure Resource Manager (ARM) JSON template according to updated network topology requirements, and subsequently deploy the template to provision a Virtual Network (VNet).

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`), `vi` text editor
* **Template Path:** `/root/arm-templates/vnet-deployment-template.json`
* **Target VNet Name:** `arm-vnet-devops`
* **Target CIDR Block:** `192.168.0.0/16`
* **Target Tags:** * `displayName`: `arm-vnet-devops`
  * `Environment`: `KKE-devops`

---

## Execution Steps

### 1. Modify the ARM Template
Utilized a terminal-based text editor to modify the JSON template directly on the deployment host. Updated the VNet resource name, adjusted the address prefix array, and extended the tags object to include the required environment metadata, ensuring strict adherence to JSON syntax formatting.

    # Snippet of the modified sections within the ARM template:
    # "name": "arm-vnet-devops",
    # "tags": {
    #   "displayName": "arm-vnet-devops",
    #   "Environment": "KKE-devops"
    # },
    # "addressPrefixes": [
    #   "192.168.0.0/16"
    # ]

### 2. Dynamically Resolve the Target Resource Group
Programmatically fetched the active sandbox resource group by querying the Azure CLI and piping the output through `grep` to isolate the specific laboratory environment identifier.

    RG_NAME=$(az group list --query '[].name' --output tsv | grep 'kml')
    echo "Target Resource Group: $RG_NAME"

### 3. Deploy the ARM Template
Executed the template deployment utilizing the `az deployment group create` command. Azure Resource Manager parsed the declarative JSON file and provisioned the virtual network statefully.

    az deployment group create \
      --resource-group $RG_NAME \
      --template-file /root/arm-templates/vnet-deployment-template.json

### 4. Verification
Confirmed the successful execution of the IaC deployment via the returned JSON payload. The `provisioningState` property within the deployment output verified the infrastructure was successfully instantiated.

    # Expected State Indicator in JSON Output:
    # "provisioningState": "Succeeded"

---

## Troubleshooting Summary
* **Missing Editor Dependency:** Encountered a `command not found` error when attempting to use the `nano` text editor to modify the JSON file, as it was not pre-installed on the provided client host.
* **Resolution:** Pivoted to using the `vi` text editor, which is natively available on almost all POSIX-compliant Linux distributions, to successfully edit the ARM template and maintain deployment momentum.