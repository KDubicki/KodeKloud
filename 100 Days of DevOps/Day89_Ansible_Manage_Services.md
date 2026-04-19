# Nautilus DevOps Task: Day 89 - Ansible Manage Services

## Objective
The development team requires the `httpd` package to be installed, started, and enabled on all application servers in the Stratos Datacenter. The objective is to automate this process using an Ansible playbook from the `jump_host`, managing both package installation and service states simultaneously.

## Environment Details
* **Control Node:** `jump_host` (User: `thor`)
* **Target Servers:** All App Servers (`stapp01`, `stapp02`, `stapp03`)
* **Package/Service:** `httpd`
* **Working Directory:** `/home/thor/ansible/`

---

## Execution Steps

### 1. Update the Ansible Inventory
Navigated to the working directory. To ensure the playbook validation command executes seamlessly without stalling on interactive prompts or SSH key verifications, the `inventory` file was updated to explicitly include the target users, SSH passwords, and the `StrictHostKeyChecking=no` argument. Proper line breaks were ensured to prevent formatting errors.

```bash
cd /home/thor/ansible

cat << 'EOF' > inventory
stapp01 ansible_host=stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_host=stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_host=stapp03 ansible_user=banner ansible_ssh_pass=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```

### 2. Create the Ansible Playbook
Created `playbook.yml` utilizing two core modules:
* **`yum`**: To ensure the `httpd` package is installed (`state: present`).
* **`service`**: To ensure the service is running (`state: started`) and configured to start on boot (`enabled: yes`).
* **Privilege Escalation:** `become: yes` was applied at the play level to grant the necessary `root` access for package and service management.

```bash
cat << 'EOF' > playbook.yml
---
- name: Install and manage httpd service
  hosts: all
  become: yes
  tasks:
    - name: Install httpd package
      yum:
        name: httpd
        state: present

    - name: Start and enable httpd service
      service:
        name: httpd
        state: started
        enabled: yes
EOF
```

### 3. Execution and Verification
Executed the playbook using the specific validation command requested by the task constraints.

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
The successful execution confirms that the `httpd` package was deployed and the service was successfully initialized and enabled across all designated nodes.