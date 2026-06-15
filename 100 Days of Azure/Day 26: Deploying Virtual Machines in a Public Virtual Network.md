# Day 26 - Deploying Virtual Machines in a Public Virtual Network

## Objective

The Nautilus Networking Team requires a new public-facing Virtual Network (VNet) to host internet-accessible services. The objective of this task is to provision a public VNet and subnet, ensuring resources within this subnet obtain public IP addresses. Additionally, a new Virtual Machine must be deployed within this infrastructure, serving as a public application host with secure and verified inbound SSH access over the internet.

## Architecture & Environment Details

* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (azure-client)
* **Target Region:** eastus
* **Resource Group:** Dynamically resolved
* **Virtual Network Name:** datacenter-pub-vnet (CIDR: 10.0.0.0/16)
* **Subnet Name:** datacenter-pub-subnet (CIDR: 10.0.0.0/24)
* **Virtual Machine Name:** datacenter-pub-vm
* **OS Image:** Ubuntu 22.04 LTS
* **Instance Size:** Standard_B1s (Explicitly set to bypass capacity limits)
* **Network Security:** Network Security Group (NSG) with inbound SSH (Port 22) allowed
* **Storage SKU:** Standard_LRS (Enforced by policy)

*Security Note: Sensitive authentication credentials have been intentionally redacted from this public documentation to maintain operational security and secrets management best practices.*

## Execution Steps

### 1. Authenticate and Define Scope

Authenticated directly using Azure CLI. The pre-provisioned Resource Group was dynamically resolved.

```bash
RG=$(az group list --query "[0].name" -o tsv)
```

### 2. Provision the Virtual Network and Subnet

Deployed the foundational networking components in the `eastus` region. Azure allows simultaneous creation of the VNet and the initial subnet, streamlining the deployment process.

```bash
az network vnet create \
  --resource-group $RG \
  --name datacenter-pub-vnet \
  --location eastus \
  --address-prefix 10.0.0.0/16 \
  --subnet-name datacenter-pub-subnet \
  --subnet-prefix 10.0.0.0/24
```

### 3. Deploy the Virtual Machine and Public IP

Provisioned the compute instance. Unlike some cloud providers where "auto-assign public IP" is a subnet-level property, Azure allocates public IP addresses natively at the Network Interface Card (NIC) level. By defining the `--public-ip-address` parameter, a dynamic public IP was automatically generated and attached. The VM size was explicitly specified to avoid default SKU capacity constraints.

```bash
az vm create \
  --resource-group $RG \
  --name datacenter-pub-vm \
  --location eastus \
  --size Standard_B1s \
  --vnet-name datacenter-pub-vnet \
  --subnet datacenter-pub-subnet \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-address datacenter-pub-pip \
  --nsg datacenter-pub-nsg \
  --storage-sku Standard_LRS
```

### 4. Configure Network Security Group (NSG)

Explicitly forced an inbound security rule on the newly created NSG to ensure Port 22 (SSH) is accessible from the internet, fulfilling the public accessibility requirement.

```bash
az vm open-port \
  --resource-group $RG \
  --name datacenter-pub-vm \
  --port 22 \
  --priority 100
```

## Verification

Programmatically extracted the newly assigned Public IP address and successfully initiated an SSH connection to validate the compute power state, networking configuration, and NSG rules.

```bash
PIP=$(az vm show -d -g $RG -n datacenter-pub-vm --query publicIps -o tsv)
ssh -o StrictHostKeyChecking=no azureuser@$PIP
```

## Troubleshooting Summary / Edge Cases

* **Capacity Restrictions (SkuNotAvailable):** Deploying without specifying a VM size causes the Azure CLI to default to `Standard_DS1_v2`. In lab environments within the `eastus` region, this specific SKU often faces capacity exhaustion, throwing a `SkuNotAvailable` deployment error. Resolved by explicitly appending the `--size Standard_B1s` flag to allocate a highly available, alternative tier.

* **Subnet Public IP Behavior:** Azure does not utilize a subnet-level toggle for public IP assignment like AWS. The requirement to "ensure public IP is auto-assigned" was fulfilled by configuring the ARM template (via CLI) to provision and map a Public IP resource directly to the VM's primary IP Configuration during deployment.

* **Azure Policy Constraints:** Default VM creation via CLI attempts to provision a `Premium_LRS` OS disk, which often violates lab environment quotas. The `--storage-sku Standard_LRS` flag was appended to seamlessly bypass this deadlock.
