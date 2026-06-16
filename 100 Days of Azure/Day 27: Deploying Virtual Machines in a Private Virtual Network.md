# Day 27 - Deploying Virtual Machines in a Private Virtual Network

## Objective

The Nautilus DevOps team is expanding the Azure infrastructure by establishing an isolated, private Virtual Network (VNet). The objective is to provision a VNet, a dedicated subnet, and a Virtual Machine that remains entirely inaccessible from the public internet. Communication, including SSH management access, must be strictly constrained to the VNet's internal CIDR block via explicit Network Security Group (NSG) rules.

## Architecture & Environment Details

* **Cloud Provider:** Microsoft Azure

* **Tool:** Azure CLI (`azure-client`)

* **Target Region:** `centralus`

* **Resource Group:** Dynamically resolved

* **Virtual Network:** `devops-priv-vnet` (CIDR: `10.0.0.0/16`)

* **Subnet:** `devops-priv-subnet` (CIDR: `10.0.0.0/24`)

* **Network Security Group:** `devops-priv-nsg`

* **NSG Inbound Rule:** TCP Port 22, Source `10.0.0.0/16`, Destination `10.0.0.0/16`, Action: Allow

* **Virtual Machine Name:** `devops-priv-vm`

* **OS Image:** Ubuntu 22.04 LTS

* **Instance Size:** `Standard_B1s` (Prevents capacity exhaustion)

* **Storage SKU:** `Standard_LRS` (Complies with Azure Policy restrictions)

## Execution Steps

### 1. Resolve Target Resource Group

Programmatically extract the pre-provisioned resource group to ensure the infrastructure is deployed within the authorized sandbox environment.

```bash
RG=$(az group list --query "[0].name" -o tsv)
```

### 2. Provision the Private Virtual Network and Subnet

Deploy the VNet and its initial subnet strictly in the `centralus` region.

```bash
az network vnet create \
  --resource-group $RG \
  --name devops-priv-vnet \
  --location centralus \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name devops-priv-subnet \
  --subnet-prefixes 10.0.0.0/24
```

### 3. Provision the Network Security Group (NSG)

Create the NSG to govern traffic flow for the private environment.

```bash
az network nsg create \
  --resource-group $RG \
  --name devops-priv-nsg \
  --location centralus
```

### 4. Configure Explicit Internal SSH Rule

Enforce an explicit security rule allowing SSH access *only* originating from and destined to the internal `10.0.0.0/16` CIDR block.

```bash
az network nsg rule create \
  --resource-group $RG \
  --nsg-name devops-priv-nsg \
  --name Allow-SSH-Internal \
  --priority 100 \
  --source-address-prefixes 10.0.0.0/16 \
  --destination-address-prefixes 10.0.0.0/16 \
  --destination-port-ranges 22 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp
```

### 5. Deploy the Private Virtual Machine

Provision the VM and attach the newly created VNet, Subnet, and NSG. Passing the `--public-ip-address ""` parameter explicitly suppresses the default public IP allocation.

```bash
az vm create \
  --resource-group $RG \
  --name devops-priv-vm \
  --location centralus \
  --vnet-name devops-priv-vnet \
  --subnet devops-priv-subnet \
  --nsg devops-priv-nsg \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --storage-sku Standard_LRS \
  --public-ip-address "" \
  --generate-ssh-keys
```

## Verification

Verify that the VM was created successfully and confirm its assigned private IP address.

```bash
az vm show \
  --resource-group $RG \
  --name devops-priv-vm \
  --show-details \
  --query "privateIps" \
  -o tsv
```

## Troubleshooting Summary / Edge Cases

* **Unintended Public IP Allocation:** By default, the `az vm create` command attempts to provision a Public IP. This violates the strict private VNet requirement. **Workaround:** Explicitly set `--public-ip-address ""` to enforce complete isolation.

* **Azure Policy Constraints (RequestDisallowedByPolicy):** Unspecified parameters often result in the CLI defaulting to `Premium_LRS` disks, which are blocked in limited lab environments. **Workaround:** Added `--storage-sku Standard_LRS` to maintain compliance.

* **Capacity Restrictions (SkuNotAvailable):** Default VM sizes frequently hit limits in specific Azure regions. **Workaround:** Passed `--size Standard_B1s` to ensure reliable provisioning.
