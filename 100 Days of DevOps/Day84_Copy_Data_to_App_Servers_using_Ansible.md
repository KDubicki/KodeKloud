# Nautilus DevOps Task: Day 84 - Copy Data to App Servers using Ansible

## Objective
The Nautilus DevOps team needs to distribute a specific file from the jump host to all application servers in the Stratos Datacenter. The task requires creating an Ansible inventory containing all app servers and writing a playbook to securely copy `/usr/src/sysops/index.html` to the `/opt/sysops` directory on each target node.

## Environment Details
* **Control Node:** `jump_host`
* **Target Servers:** `stapp01`, `stapp02`, `stapp03`
* **Source File:** `/usr/src/sysops/index.html`
* **Destination Path:** `/opt/sysops/`
* **Working Directory:** `/home/thor/ansible/`

---

## Execution Steps

### 1. Create the Ansible Inventory
Created an INI-formatted `inventory` file defining all three application servers. To satisfy the requirement that the playbook must run without extra arguments (e.g., `--ask-pass`), the user credentials and the SSH host key bypass arguments were hardcoded into the inventory variables. 

```bash
cd /home/thor/ansible/

cat << 'EOF' > inventory
stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_user=banner ansible_ssh_pass=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```

### 2. Create the Ansible Playbook
Created `playbook.yml` utilizing the `file` module to ensure the destination directory exists, and the `copy` module to transfer the file. `become: yes` was required to escalate privileges, as writing to the `/opt/` directory demands root access.

```bash
cat << 'EOF' > playbook.yml
---
- name: Copy data to all App Servers
  hosts: all
  become: yes
  tasks:
    - name: Ensure /opt/sysops directory exists
      file:
        path: /opt/sysops
        state: directory

    - name: Copy index.html to /opt/sysops
      copy:
        src: /usr/src/sysops/index.html
        dest: /opt/sysops/index.html
EOF
```

### 3. Execution and Verification
Executed the playbook using the validation command requested by the task.

```bash
ansible-playbook -i inventory playbook.yml
```

**Expected Output Recap:**
```text
PLAY RECAP *********************************************************************
stapp01                    : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
The output successfully confirms the file was copied and directory state was ensured across all nodes simultaneously.