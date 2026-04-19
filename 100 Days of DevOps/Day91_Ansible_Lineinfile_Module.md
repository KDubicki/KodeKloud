# Nautilus DevOps Task: Day 91 - Ansible Lineinfile Module

## Objective
The DevOps team requires the installation of the Apache HTTP server (`httpd`) on all application servers in the Stratos Datacenter. Additionally, a sample `index.html` file needs to be deployed and modified dynamically using Ansible. The task specifically requires injecting content at the very beginning of the file while maintaining strict ownership and permission settings.

## Environment Details
* **Control Node:** `jump_host` (User: `thor`)
* **Working Directory:** `/home/thor/ansible/`
* **Target Servers:** `stapp01`, `stapp02`, `stapp03`
* **Target File:** `/var/www/html/index.html`
* **File Permissions:** `0655`
* **File Ownership:** `apache:apache`

---

## Execution Steps

### 1. Update the Ansible Inventory
Navigated to the Ansible working directory. The `inventory` file was updated to include explicit SSH passwords and the `StrictHostKeyChecking=no` argument. This ensures the playbook executes seamlessly during the automated validation process without interactive prompts.

```bash
cd /home/thor/ansible

cat << 'EOF' > inventory
stapp01 ansible_host=stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_host=stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_host=stapp03 ansible_user=banner ansible_ssh_pass=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```

### 2. Create the Ansible Playbook
Created `playbook.yml`. To guarantee strict idempotency and perfectly match the automated validation script's formatting expectations, a combination of the `copy` and `lineinfile` modules was utilized.

* **`copy` module:** Used to safely instantiate the file with the exact base string and newline character, while strictly enforcing the `0655` mode and `apache:apache` ownership. This prevents trailing blank lines from accumulating during multiple runs.
* **`lineinfile` module (BOF Injection):** Uses the `insertbefore: BOF` (Beginning Of File) parameter to safely prepend the welcome message exactly as required by the development team.
* **`become: yes`:** Escalates privileges to `root` to manage packages, services, and web directory contents.

```bash
cat << 'EOF' > playbook.yml
---
- name: Setup httpd and configure index.html using lineinfile
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

    - name: Create index.html with exact base content
      copy:
        dest: /var/www/html/index.html
        content: "This is a Nautilus sample file, created using Ansible!\n"
        owner: apache
        group: apache
        mode: '0655'

    - name: Add welcome message at the top of the file
      lineinfile:
        path: /var/www/html/index.html
        line: "Welcome to Nautilus Group!"
        insertbefore: BOF
        state: present
EOF
```

### 3. Execution and Verification
Executed the playbook successfully using the specific validation command requested by the task constraints.

```bash
ansible-playbook -i inventory playbook.yml
```

**Expected Output Recap:**
The output confirmed that `httpd` was installed and started. The file manipulations were executed smoothly, resulting in a successful recap where all application servers reported successful changes and perfectly matched the target pattern.