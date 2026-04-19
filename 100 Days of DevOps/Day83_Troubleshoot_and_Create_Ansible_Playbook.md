# Nautilus DevOps Task: Day 83 - Troubleshoot and Create Ansible Playbook

## Objective
Configure an Ansible environment on the jump host to execute a task on `App Server 1`. This requires fixing an incomplete `inventory` file by adding the target host along with its connection variables, bypassing SSH host key checking, and writing a `playbook.yml` to create an empty file (`/tmp/file.txt`) on the target server.

## Environment Details
* **Jump Host User:** `thor`
* **Target Server:** App Server 1 (`stapp01`)
* **Target User:** `tony`
* **Target Password:** `Ir0nM@n`
* **Working Directory:** `/home/thor/ansible/`

---

## Execution Steps

### 1. Update the Inventory File (and Fix SSH Key Checking)
Navigated to the Ansible working directory and configured the `inventory` file. To satisfy the requirement that the playbook must run without any extra arguments (like `--ask-pass`), the SSH connection variables (`ansible_user` and `ansible_ssh_pass`) were mapped directly to the host. 

*Troubleshooting Note:* Ansible failed initially with a Strict Host Key Checking error. To fix this, `ansible_ssh_common_args='-o StrictHostKeyChecking=no'` was added to bypass the interactive `yes/no` SSH fingerprint prompt.

```bash
cd /home/thor/ansible/

cat << 'EOF' > inventory
stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```

### 2. Create the Ansible Playbook
Created the `playbook.yml` file. The playbook targets the `stapp01` host defined in the inventory and utilizes the built-in Ansible `file` module to ensure an empty file is created at the designated path.

```bash
cat << 'EOF' > playbook.yml
---
- name: Create an empty file on App Server 1
  hosts: stapp01
  become: yes
  tasks:
    - name: Ensure /tmp/file.txt exists and is empty
      file:
        path: /tmp/file.txt
        state: touch
EOF
```

### 3. Execution and Verification
Executed the playbook using the specific validation command requested by the task.

```bash
ansible-playbook -i inventory playbook.yml
```

**Expected Output:**
```text
PLAY [Create an empty file on App Server 1] ************************************

TASK [Gathering Facts] *********************************************************
ok: [stapp01]

TASK [Ensure /tmp/file.txt exists and is empty] ********************************
changed: [stapp01]

PLAY RECAP *********************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
The `changed=1` status confirms that the `/tmp/file.txt` was successfully created on `App Server 1`.