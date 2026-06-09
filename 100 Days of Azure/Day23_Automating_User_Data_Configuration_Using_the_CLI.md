# Day 23 - Automating User Data Configuration Using the CLI

## Objective

The Nautilus DevOps Team is establishing the initial infrastructure for a critical application. The objective of this task is to provision an Azure Virtual Machine (`devops-vm`) to act as a web server. To ensure reliable, reproducible deployments without manual intervention, the configuration must utilize User Data (`cloud-init`) to automatically install and start the Nginx web service upon boot. Additionally, the Network Security Group (NSG) must be configured to permit public HTTP traffic.

## Architecture & Environment Details

* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`), `cloud-init`
* **Target Region:** `eastus`
* **Resource Group:** Dynamically resolved (Pre-provisioned lab environment)
* **VM Name:** `devops-vm`
* **OS Image:** Ubuntu 22.04 LTS (`Ubuntu2204`)
* **Instance Size:** `Standard_B1s`
* **OS Disk SKU:** `Standard_LRS` (Enforced by Azure Policy)
* **Automation:** `cloud-init.txt` payload applied via `--custom-data`
* **Network Security:** Inbound HTTP (Port 80) allowed from the internet

## Execution Steps

### 1. Dynamically Resolve the Resource Group

Due to strict Role-Based Access Control (RBAC) in the laboratory environment, creating new resource groups is restricted. Programmatically fetched the pre-provisioned resource group to ensure the VM is deployed within the authorized boundaries.

```bash
RG_NAME=$(az group list --query "[0].name" -o tsv)
echo "Active Resource Group: $RG_NAME"
```

### 2. Generate the Cloud-Init Payload

Created a declarative YAML payload on the deployment host. This file instructs the cloud instance to upgrade packages, install the Nginx daemon, and ensure it is enabled and started completely hands-off.

```bash
cat <<EOF > cloud-init.txt
#cloud-config
package_upgrade: true
packages:
  - nginx
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
EOF
```

### 3. Provision the Virtual Machine

Executed the compute deployment utilizing the `az vm create` command. The `--custom-data` flag securely injects the `cloud-init` file. The `--storage-sku Standard_LRS` parameter was strictly enforced to comply with active Azure Policies.

```bash
az vm create \\
  --resource-group $RG_NAME \\
  --name devops-vm \\
  --image Ubuntu2204 \\
  --admin-username azureuser \\
  --generate-ssh-keys \\
  --custom-data cloud-init.txt \\
  --size Standard_B1s \\
  --storage-sku Standard_LRS
```

### 4. Configure the Network Security Group (NSG)

Modified the auto-generated NSG to explicitly permit inbound HTTP traffic using the simplified `open-port` wrapper.

```bash
az vm open-port \\
  --resource-group $RG_NAME \\
  --name devops-vm \\
  --port 80 \\
  --priority 100
```

## Verification

Programmatically extracted the dynamically assigned public IP address and validated the Nginx service's response via a curl request.

```bash
# Extract Public IP
PUBLIC_IP=$(az vm show -d -g $RG_NAME -n devops-vm --query publicIps -o tsv)

# Verify HTTP Response
curl -I http://$PUBLIC_IP