# Day 13 - SSH into an Azure Virtual Machine

## Objective
The Nautilus DevOps team is enforcing secure access policies across its Azure infrastructure. The objective of this task is to configure passwordless SSH access specifically for the `root` user. This requires securely transferring the public SSH key from the deployment host (`azure-client`) to the `authorized_keys` file of the `root` profile on the target Azure VM (`xfusion-vm`), ensuring strict file permission compliance.

## Environment Details
* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI & OpenSSH
* **Target VM Name:** `xfusion-vm`
* **Default SSH User:** `azureuser`
* **Target SSH User:** `root`
* **Source Key Path:** `/root/.ssh/id_rsa.pub`

---

## Execution Steps

### 1. Dynamically Resolve the VM's Public IP
Fetched the pre-provisioned resource group and programmatically extracted the dynamically assigned Public IP of the target virtual machine to establish the SSH connection.

    RG_NAME=$(az group list --query "[0].name" -o tsv)
    
    VM_IP=$(az vm show -d \
      --resource-group $RG_NAME \
      --name xfusion-vm \
      --query publicIps \
      --output tsv)
    
    echo "Resolved Target IP: $VM_IP"

### 2. Overwrite the Root Authorized Keys File
Utilized the standard `azureuser` profile to securely bridge the connection. A one-liner script was passed through SSH to extract the local root public key and elevate privileges via `sudo`. 

*Crucial step:* The `tee` command was explicitly used without the append (`-a`) flag to completely overwrite the existing `authorized_keys` file. This is required because Azure's `cloud-init` default configuration injects a restricted key with a `command=` prefix that actively blocks direct root shell access.

    PUB_KEY=$(cat /root/.ssh/id_rsa.pub)
    
    ssh -o StrictHostKeyChecking=no azureuser@$VM_IP \
      "sudo mkdir -p /root/.ssh && \
       echo '$PUB_KEY' | sudo tee /root/.ssh/authorized_keys > /dev/null && \
       sudo chmod 700 /root/.ssh && \
       sudo chmod 600 /root/.ssh/authorized_keys"

### 3. Verification of Passwordless Access
Validated the configuration by initiating a direct SSH connection to the VM explicitly using the `root` user profile. The connection successfully bypassed password authentication and the Azure default restriction message, confirming the clean key was registered correctly.

    ssh root@$VM_IP
    # Successfully authenticated and accessed the root shell on xfusion-vm.
    exit

---

## Troubleshooting Summary
* **Root Login Rejected by Cloud-Init:** Initial login attempt returned `Please login as the user "azureuser" rather than the user "root"`.
* **Resolution:** Discovered that Azure prepends a restriction `command` string to the `authorized_keys` file for the root user during VM provisioning. Resolved by completely overwriting the file with a clean `id_rsa.pub` string instead of appending to it.