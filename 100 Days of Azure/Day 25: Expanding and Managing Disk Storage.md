# Day 25 - Expanding and Managing Disk Storage

## Objective

The Nautilus DevOps team requires storage capacity expansion for an existing virtual machine (`nautilus-vm`) to handle increased workloads. The objective is twofold: resize the primary OS disk from 32Gi to 64Gi and provision a new 64Gi Standard HDD data disk (`nautilus-disk`). The new data disk must be persistently mounted at `/mnt/nautilus-disk` inside the virtual machine.

## Architecture & Environment Details

* **Cloud Provider:** Microsoft Azure
* **Tool:** Azure CLI (`azure-client`) / Azure VM Run Command
* **Target VM Name:** `nautilus-vm`
* **OS Disk Modification:** Expand from 32 GiB to 64 GiB
* **New Data Disk Name:** `nautilus-disk`
* **Data Disk Specifications:** 64 GiB, Standard HDD (`Standard_LRS`)
* **Mount Point:** `/mnt/nautilus-disk`

*Security Note: Sensitive lab credentials have been redacted from this documentation following zero-trust best practices.*

## Execution Steps

### 1. Resolve Resource Group

Dynamically retrieved the active sandbox Resource Group using the existing authenticated session.

```bash
RG=$(az group list --query "[0].name" -o tsv)
```

### 2. Expand the Existing OS Disk

Azure requires compute instances to be in a deallocated state before their primary OS disks can be resized at the hardware level.

```bash
# Retrieve OS Disk Name dynamically
OS_DISK=$(az vm show -g $RG -n nautilus-vm --query "storageProfile.osDisk.name" -o tsv)

# Deallocate VM to release the storage lock
az vm deallocate -g $RG -n nautilus-vm

# Resize OS disk to 64 GiB
az disk update -g $RG -n $OS_DISK --size-gb 64
```

### 3. Provision and Attach the New Data Disk

Created a standalone managed disk using the `Standard_LRS` SKU to comply with standard HDD requirements, then attached it directly to the virtual machine.

```bash
# Create the managed data disk
az disk create -g $RG -n nautilus-disk --size-gb 64 --sku Standard_LRS

# Attach the new disk to the VM
az vm disk attach -g $RG --vm-name nautilus-vm --name nautilus-disk

# Restart the VM to apply hardware changes
az vm start -g $RG -n nautilus-vm
```

### 4. Configure Partitions and Mount the Disk (In-Guest Execution)

Utilized Azure's `Run Command` to execute infrastructure-as-code scripting directly inside the VM without requiring external SSH key management. This script handles filesystem expansion for the OS disk and formats/mounts the newly attached data disk persistently using its UUID.

```bash
az vm run-command invoke -g $RG -n nautilus-vm --command-id RunShellScript --scripts "
# 1. Expand the OS partition and filesystem (sda1)
sudo growpart /dev/sda 1 || true
sudo resize2fs /dev/sda1 || true

# 2. Partition, format, and mount the new data disk (sdc)
DATA_DISK=\\"/dev/sdc\\"
sudo parted \\$DATA_DISK --script mklabel gpt mkpart primary ext4 0% 100%
sudo mkfs.ext4 \\${DATA_DISK}1
sudo mkdir -p /mnt/nautilus-disk
sudo mount \\${DATA_DISK}1 /mnt/nautilus-disk

# 3. Ensure persistent mounting on reboot by appending to /etc/fstab via UUID
UUID=\\$(blkid -s UUID -o value \\${DATA_DISK}1)
echo \\"UUID=\\$UUID /mnt/nautilus-disk ext4 defaults 0 0\\" | sudo tee -a /etc/fstab
"
```

## Verification

To ensure both the OS disk was expanded and the new data disk was successfully mounted, the `df -h` and `lsblk` commands were executed inside the guest OS.

```bash
az vm run-command invoke -g $RG -n nautilus-vm --command-id RunShellScript --scripts "df -h; lsblk"
```

**Expected Output Indicators:**

* `/dev/sda1` should display a total size close to `64G`.
* `/dev/sdc1` should be present, sized at `64G`, and mounted exactly at `/mnt/nautilus-disk`.

## Troubleshooting Summary / Edge Cases

* **OS Disk Resize Restriction:** Attempting to run `az disk update` on the OS disk while the VM is running results in an operational lock. **Resolution:** Explicitly invoked `az vm deallocate` before modifying hardware profiles.
* **Persistent Mount Failures:** Relying on standard device names (`/dev/sdc1`) in `/etc/fstab` can lead to boot failures in Azure if SCSI controllers reassign drive letters during maintenance. **Resolution:** Dynamically extracted the `UUID` of the newly formatted partition using `blkid` and injected it into `fstab` to guarantee flawless reboots.
