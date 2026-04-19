# Nautilus DevOps Task: Day 90 - Managing ACLs Using Ansible

## Objective
The Nautilus DevOps team requires specific empty files to be created on the application servers in the Stratos Datacenter. These files must be owned by the `root` user, but specific application users and groups require fine-grained Access Control List (ACL) permissions applied to them. The objective is to automate this infrastructure configuration using an Ansible playbook.

## Environment Details
* **Control Node:** `jump_host` (User: `thor`)
* **Working Directory:** `/home/thor/ansible/`
* **App Server 1 (`stapp01`):** Create `/opt/data/blog.txt` | ACL: read `(r)` for group `tony`
* **App Server 2 (`stapp02`):** Create `/opt/data/story.txt` | ACL: read+write `(rw)` for user `steve`
* **App Server 3 (`stapp03`):** Create `/opt/data/media.txt` | ACL: read+write `(rw)` for group `banner`

---

## Execution Steps

### 1. Configure the Ansible Inventory
Navigated to the working directory. To ensure the automated validation script executes without interactive credential prompts, the `inventory` file was updated with explicit SSH passwords and the `StrictHostKeyChecking=no` parameter.

```bash
cd /home/thor/ansible

cat << 'EOF' > inventory
stapp01 ansible_host=stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_host=stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_host=stapp03 ansible_user=banner ansible_ssh_pass=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```

### 2. Create the Ansible Playbook
Created `playbook.yml`. To maintain clear separation of logic given the highly specific requirements per server, the playbook was structured into three distinct plays. 
* The `file` module was used to touch the files and explicitly set `root:root` ownership.
* The `acl` module was utilized to apply the granular permissions (using varying `etype` parameters for `user` vs `group`).
* `become: yes` was applied to ensure the necessary privileges to manage root-owned files and ACLs.

```bash
cat << 'EOF' > playbook.yml
---
- name: Manage ACLs on App Server 1
  hosts: stapp01
  become: yes
  tasks:
    - name: Create empty file blog.txt
      file:
        path: /opt/data/blog.txt
        state: touch
        owner: root
        group: root

    - name: Set ACL for group tony
      acl:
        path: /opt/data/blog.txt
        entity: tony
        etype: group
        permissions: r
        state: present

- name: Manage ACLs on App Server 2
  hosts: stapp02
  become: yes
  tasks:
    - name: Create empty file story.txt
      file:
        path: /opt/data/story.txt
        state: touch
        owner: root
        group: root

    - name: Set ACL for user steve
      acl:
        path: /opt/data/story.txt
        entity: steve
        etype: user
        permissions: rw
        state: present

- name: Manage ACLs on App Server 3
  hosts: stapp03
  become: yes
  tasks:
    - name: Create empty file media.txt
      file:
        path: /opt/data/media.txt
        state: touch
        owner: root
        group: root

    - name: Set ACL for group banner
      acl:
        path: /opt/data/media.txt
        entity: banner
        etype: group
        permissions: rw
        state: present
EOF
```

### 3. Execution and Verification
Executed the playbook successfully using the specific validation command requested by the task constraints.

```bash
ansible-playbook -i inventory playbook.yml
```

**Expected Output:**
The playbook cleanly targeted each server individually, modified the state for both the file creation and the ACL application, and concluded with a success recap across the infrastructure.