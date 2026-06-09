# Day 23 - Automating User Data Configuration Using the CLI

## Objective
The Nautilus DevOps Team requires a new virtual machine to host a web server for a critical application. The objective is to provision an Azure VM named `devops-vm` configured with Nginx via a custom initialization script (User Data) and secure it to allow public HTTP traffic on port 80. Ensuring that the server is correctly configured and accessible from the internet is crucial for the upcoming deployment phase.

## Architecture & Environment Details
- **Cloud Provider**: Microsoft Azure
- **Tool**: Azure CLI (`azure-client`)
- **Target Region**: eastus
- **VM Name**: devops-vm
- **OS Image**: Ubuntu 22.04 LTS (`Ubuntu2204`)
- **Instance Size**: Standard_B1s (Optimized for capacity constraints)
- **User Data**: `cloud-init.yml` (Nginx installation and startup)
- **Network Security**: NSG configured to permit inbound HTTP (Port 80)

## Execution Steps

### 1. Dynamically Resolve the Resource Group
Programmatically fetched the pre-provisioned resource group to ensure the infrastructure is deployed strictly within the monitored laboratory boundaries.
```bash
RG_NAME=$(az group list --query "[0].name" -o tsv)
echo "Target Resource Group: $RG_NAME"
```

### 2. Prepare the Cloud-Init Configuration
Created a declarative `#cloud-config` YAML payload on the deployment host. This payload defines the desired end-state of the server (package upgrades, nginx installation, and daemon initialization) without requiring interactive SSH sessions.
```bash
cat <<EOF > cloud-init.yml
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
Executed the compute deployment utilizing the `az vm create` command. The `--custom-data` parameter was passed to inject the initialization script. The `--storage-sku Standard_LRS` argument was explicitly supplied to bypass potential Azure Policy restrictions against premium storage allocation in sandbox environments.
```bash
az vm create \\
  --resource-group $RG_NAME \\
  --name devops-vm \\
  --image Ubuntu2204 \\
  --size Standard_B1s \\
  --storage-sku Standard_LRS \\
  --location eastus \\
  --custom-data cloud-init.yml \\
  --generate-ssh-keys
```

### 4. Configure the Network Security Group (NSG)
Explicitly created an NSG rule to allow inbound HTTP traffic from the internet, a prerequisite for the web server to be reachable publicly.
```bash
az vm open-port \\
  --resource-group $RG_NAME \\
  --name devops-vm \\
  --port 80 \\
  --priority 100
```

## Verification
Extracted the dynamically allocated public IP address and performed an HTTP GET request to validate the operational status of the Nginx server.
```bash
# Extract Public IP
PUBLIC_IP=$(az vm show -d -g $RG_NAME -n devops-vm --query "publicIps" -o tsv)
echo "Public IP: $PUBLIC_IP"

# Validate Web Server Response
curl -I http://$PUBLIC_IP
```

## Troubleshooting Summary / Edge Cases
- **SkuNotAvailable Error:** The deployment might fail initially with a `SkuNotAvailable` exception if attempting to use default SKUs (like `Standard_DS1_v2`) due to capacity restrictions in the `eastus` region. Resolved by explicitly declaring `--size Standard_B1s`.
- **Azure Policy Block (Ghost Resource):** If a strict Azure Policy rejects the default Premium OS Disk, it can leave a "ghost" VM state that blocks subsequent deployments with the same name. Resolved by executing `az resource delete --ids <VM_ID>` to forcefully purge the corrupted state before re-deploying with `--storage-sku Standard_LRS`.
- **Asynchronous Execution Delay:** Immediate HTTP requests to the public IP right after the `az vm create` command finishes will result in a `Connection refused` error. This is expected behavior; the CLI reports success when the virtual hardware is allocated, but the `cloud-init` script requires an additional 1-2 minutes to download and initialize the Nginx daemon asynchronously within the guest OS.
