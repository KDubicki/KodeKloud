# Nautilus DevOps Task: Day 87 - Ansible Install Package

## Objective
The Nautilus Application development team requires a specific package (`chrony`) to be installed across all application servers in the Stratos Datacenter to ensure time synchronization. The objective is to automate this installation using an Ansible playbook utilizing the `yum` module, executed from the `jump_host`.

## Environment Details
* **Control Node:** `jump_host` (User: `thor`)
* **Target Servers:** `stapp01`, `stapp02`, `stapp03`
* **Package to Install:** `chrony`
* **Working Directory:** `/home/thor/playbook/`

---

## Execution Steps

### 1. Create the Ansible Inventory
Created the `inventory` file defining all three application servers. To meet the requirement that the playbook must execute without any interactive prompts or additional arguments, SSH credentials and the SSH host key bypass argument (`StrictHostKeyChecking=no`) were hardcoded into the inventory variables.

```bash
mkdir -p /home/thor/playbook
cd /home/thor/playbook/

cat << 'EOF' > inventory
stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_user=banner ansible_ssh_pass=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```

### 2. Create the Ansible Playbook
Created `playbook.yml` utilizing the Ansible `yum` module to handle the package installation. 
* **Privilege Escalation:** `become: yes` was applied at the play level to ensure the tasks are executed with `root` privileges, which is strictly required for package management.
* **Idempotency:** The state was set to `present`, ensuring the module only installs the package if it is not already installed.

```bash
cat << 'EOF' > playbook.yml
---
- name: Install chrony on all app servers
  hosts: all
  become: yes
  tasks:
    - name: Install chrony package
      yum:
        name: chrony
        state: present
EOF
```

### 3. Execution and Verification
Executed the playbook using the specific validation command requested by the task requirements.

```bash
ansible-playbook -i inventory playbook.yml
```

**Expected Output Recap:**
```text
PLAY RECAP *********************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
The successful execution confirms that the `chrony` package was successfully installed across all designated application servers.