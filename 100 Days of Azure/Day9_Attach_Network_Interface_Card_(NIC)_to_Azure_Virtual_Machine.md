# Day 9 - Attach Network Interface Card (NIC) to Azure Virtual Machine

## Objective
The Nautilus xfusion DevOps team continues their phased Azure migration. The goal of this task is to manage the network connectivity of an existing compute resource by attaching an available Network Interface Card (NIC), named `xfusion-nic`, to a deployed Virtual Machine named `xfusion-vm`.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`)
* **Region:** `westus`
* **Target VM Name:** `xfusion-vm`
* **Network Interface (NIC) Name:** `xfusion-nic`

---

## Execution Steps

### 1. Dynamically Resolve the Resource Group
Fetched the pre-provisioned resource group dynamically. This programmatic approach ensures the operational context is strictly bound to the active laboratory environment.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    echo "Target Resource Group: $RG_NAME"

### 2. Deallocate the Virtual Machine
Azure architecture requires a VM with a single network interface to be fully stopped and deallocated before hardware-level network topologies can be altered.

    az vm deallocate \
      --resource-group $RG_NAME \
      --name xfusion-vm

### 3. Attach the Network Interface to the VM
Executed the procedure utilizing the `az vm nic add` command on the deallocated instance. This effectively links the decoupled network interface resource to the compute instance.

    az vm nic add \
      --resource-group $RG_NAME \
      --vm-name xfusion-vm \
      --nics xfusion-nic

### 4. Restart and Initialize the Virtual Machine
Following the successful attachment, the VM was powered back on to complete its initialization phase, fulfilling the task requirement that the VM must be running prior to task submission.

    az vm start \
      --resource-group $RG_NAME \
      --name xfusion-vm

---

## Troubleshooting Summary
* **Hardware Modification Restriction:** Encountered the `AddingOrDeletingNetworkInterfacesOnARunningVirtualMachineNotSupported` error during the initial attachment attempt.
* **Resolution:** Adapted the workflow to incorporate the VM lifecycle states (`Deallocate` -> `Attach` -> `Start`). Modifying the underlying network interface count requires releasing the compute allocation temporarily.