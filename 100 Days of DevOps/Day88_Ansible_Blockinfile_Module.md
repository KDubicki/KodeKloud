# Nautilus DevOps Task: Day 88 - Ansible Blockinfile Module

## Objective
The Nautilus DevOps team requires the installation and configuration of the Apache HTTP server (`httpd`) across all application servers in the Stratos Datacenter. Additionally, a sample web page must be deployed using the Ansible `blockinfile` module, ensuring specific file ownership and permissions are applied.

## Environment Details
* **Control Node:** `jump_host` (User: `thor`)
* **Target Servers:** All App Servers (`stapp01`, `stapp02`, `stapp03`)
* **Target File:** `/var/www/html/index.html`
* **File Permissions:** `0755`
* **File Owner/Group:** `apache`
* **Working Directory:** `/home/thor/ansible/`

---

## Execution Steps

### 1. Create the Ansible Playbook
Navigated to the predefined working directory (`/home/thor/ansible/`) which already contained the pre-configured `inventory` file. Created `playbook.yml` with tasks to handle the package installation, service management, and file generation.

* **Modules Used:**
  * `yum`: To ensure the `httpd` package is installed (`state: present`).
  * `service`: To ensure the `httpd` daemon is started and enabled to survive reboots.
  * `blockinfile`: To insert the exact multi-line string required by the development team. The `create: yes` parameter was utilized to generate the file if it didn't exist, while also strictly enforcing the `0755` mode and `apache:apache` ownership. 

*(Note: Default markers were used for `blockinfile` as explicitly required by the task constraints, and careful attention was paid to the exact whitespace in the provided text block).*

```bash
cat << 'EOF' > playbook.yml
---
- name: Setup httpd and deploy sample web page
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

    - name: Deploy sample index.html using blockinfile
      blockinfile:
        path: /var/www/html/index.html
        create: yes
        owner: apache
        group: apache
        mode: '0755'
        block: |
          Welcome to XfusionCorp!
          This is  Nautilus sample file, created using Ansible!
          Please do not modify this file manually!
EOF
```

### 2. Execution and Verification
Executed the playbook using the specific validation command requested by the task requirements, confirming that `become: yes` handled privilege escalation natively.

```bash
ansible-playbook -i inventory playbook.yml
```

**Expected Output Recap:**
```text
PLAY RECAP *********************************************************************
stapp01                    : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
The successful execution confirms that the Apache server is operational and the `blockinfile` module successfully injected the sample content with the correct default markers and strict permissions.