# Nautilus DevOps Task: Day 85 - Create Files on App Servers using Ansible

## Objective
The Nautilus DevOps team requires an Ansible playbook to create a blank file at `/usr/src/opt.txt` across all three application servers. The file must have strict `0644` permissions and dynamic ownership based on the target server (`tony` for App Server 1, `steve` for App Server 2, and `banner` for App Server 3).

## Environment Details
* **Control Node:** `jump_host`
* **Target Servers:** `stapp01`, `stapp02`, `stapp03`
* **File Path:** `/usr/src/opt.txt`
* **Permissions:** `0644`
* **Working Directory:** `~/playbook/`

---

## Execution Steps

### 1. Create the Ansible Inventory
Created the `inventory` file defining all three application servers. SSH credentials and the `StrictHostKeyChecking=no` argument were hardcoded into the inventory variables so the playbook could be executed without any interactive prompts (`--ask-pass`).

```bash
mkdir -p ~/playbook
cd ~/playbook/

cat << 'EOF' > inventory
stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_user=banner ansible_ssh_pass=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```

### 2. Create the Ansible Playbook
Created `playbook.yml` utilizing the `file` module. 
* **Dynamic Ownership:** Instead of writing three separate tasks, the `owner` and `group` parameters were dynamically assigned using the `{{ ansible_user }}` variable. Since the SSH users align perfectly with the required file owners for each respective server in the Nautilus architecture, this ensures the correct ownership is applied per host natively.
* **Privilege Escalation:** `become: yes` was implemented to grant root access necessary for creating files in the `/usr/src/` directory.

```bash
cat << 'EOF' > playbook.yml
---
- name: Create files with dynamic ownership on app servers
  hosts: all
  become: yes
  tasks:
    - name: Create blank file /usr/src/opt.txt
      file:
        path: /usr/src/opt.txt
        state: touch
        mode: '0644'
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
EOF
```

### 3. Execution and Verification
Executed the playbook using the specific validation command requested by the task.

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
The successful execution confirms that the file was created on all target nodes with the correct dynamic ownership and permissions.