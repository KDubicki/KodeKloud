# Nautilus DevOps Task: Day 92 - Managing Jinja2 Templates Using Ansible

## Objective
The Nautilus DevOps team is developing a reusable Ansible Role for `httpd` installation and configuration. The objective of this task is to integrate a Jinja2 template into this role to dynamically generate the `index.html` file on `App Server 2`. The template must dynamically resolve the server's hostname and assign file ownership to the specific sudo user of the managed node.

## Environment Details
* **Control Node:** `jump_host` (User: `thor`)
* **Target Server:** App Server 2 (`stapp02`)
* **Role Path:** `/home/thor/ansible/role/httpd/`
* **Template Path:** `/var/www/html/index.html`
* **File Permissions:** `0755`
* **Dynamic Ownership:** `steve` (Resolved dynamically via `ansible_user`)

---

## Execution Steps

### 1. Update the Ansible Inventory
Navigated to the Ansible working directory. The `inventory` file was updated to include explicit SSH passwords and the `StrictHostKeyChecking=no` argument to ensure seamless, password-less playbook execution during automated validation.

```bash
cd /home/thor/ansible

cat << 'EOF' > inventory
stapp01 ansible_host=stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_host=stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_host=stapp03 ansible_user=banner ansible_ssh_pass=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```

### 2. Configure the Main Playbook
Updated the primary `playbook.yml` file to target `App Server 2` (`stapp02`) and call the in-development `httpd` role, ensuring privilege escalation (`become: yes`) was enabled at the play level.

```bash
cat << 'EOF' > playbook.yml
---
- name: Run httpd role on App Server 2
  hosts: stapp02
  become: yes
  roles:
    - role/httpd
EOF
```

### 3. Create the Jinja2 Template
Created the `templates` directory within the role structure and drafted the `index.html.j2` Jinja2 template. The Ansible built-in `{{ inventory_hostname }}` variable was utilized to dynamically inject the server's name into the rendered file without hardcoding.

```bash
mkdir -p /home/thor/ansible/role/httpd/templates

cat << 'EOF' > /home/thor/ansible/role/httpd/templates/index.html.j2
This file was created using Ansible on {{ inventory_hostname }}
EOF
```

### 4. Append the Template Task to the Role
Appended the deployment task to the existing `/role/httpd/tasks/main.yml` file. 
* **Formatting Fix:** An empty `echo` command was executed first to append a missing newline character to the preexisting file, preventing YAML syntax errors during concatenation.
* **`template` module:** Chosen over `copy` to ensure Jinja2 variables were correctly parsed and rendered on the target node.
* **Dynamic Ownership:** The `owner` and `group` were assigned using the `{{ ansible_user }}` variable.

```bash
# Fix missing trailing newline in the existing tasks file
echo "" >> /home/thor/ansible/role/httpd/tasks/main.yml

# Append the new template task
cat << 'EOF' >> /home/thor/ansible/role/httpd/tasks/main.yml
- name: Deploy index.html template
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
    mode: '0755'
    owner: "{{ ansible_user }}"
    group: "{{ ansible_user }}"
EOF
```

### 5. Execution and Verification
Executed the playbook successfully using the specific validation command requested by the task constraints.

```bash
ansible-playbook -i inventory playbook.yml
```

**Expected Output Recap:**
The output confirmed that the role was successfully applied to `stapp02`. The HTTP daemon was managed correctly by the preexisting tasks, and the new template task dynamically generated the `index.html` file with the correct content (`This file was created using Ansible on stapp02`) and permissions.