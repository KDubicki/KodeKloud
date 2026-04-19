# Nautilus DevOps Task: Day 93 - Using Ansible Conditionals

## Objective
The Nautilus DevOps team is focusing on training members to utilize Ansible's conditional statements (`when`). The goal of this task is to distribute specific IT administration files from a central location on the `jump_host` to various application servers based on their node names, ensuring specific ownership and restrictive permissions are applied.

## Environment Details
* **Control Node:** `jump_host` (User: `thor`)
* **Working Directory:** `/home/thor/ansible/`
* **Source Directory:** `/usr/src/itadmin/`
* **Destination Directory:** `/opt/itadmin/`
* **Execution Requirement:** Playbook must target `hosts: all`
* **Condition Variable:** `ansible_nodename`
* **File Permissions:** `0744`

**Task Matrix:**
| Target Server | File Name | Owner/Group | Destination |
|---------------|-----------|-------------|-------------|
| App Server 1 (`stapp01`) | `blog.txt` | `tony` | `/opt/itadmin/blog.txt` |
| App Server 2 (`stapp02`) | `story.txt` | `steve` | `/opt/itadmin/story.txt` |
| App Server 3 (`stapp03`) | `media.txt` | `banner` | `/opt/itadmin/media.txt` |

---

## Execution Steps

### 1. Configure the Ansible Inventory
The `inventory` file was configured to allow the validation script to run without interactive password prompts. It includes SSH credentials and the `StrictHostKeyChecking=no` argument.

```bash
cd /home/thor/ansible

cat << 'EOF' > inventory
stapp01 ansible_host=stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp02 ansible_host=stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
stapp03 ansible_host=stapp03 ansible_user=banner ansible_ssh_pass=BigGr33n ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
```

### 2. Create the Ansible Playbook
Created `playbook.yml` targeting `hosts: all`. 
* **Optimization:** Instead of creating three separate tasks, a single task was used with a `loop` to iterate through a list of dictionaries containing the mapping for each server.
* **Conditional Logic:** The `when` statement evaluates the `ansible_nodename` gathered fact against the `target_host` in the current loop item. This ensures that each server only copies the file intended for it.
* **Privilege Escalation:** `become: yes` was used to ensure the `/opt/itadmin` directory could be created and managed by `root`.

```yaml
---
- name: Copy IT Admin files using conditionals
  hosts: all
  become: yes
  tasks:
    - name: Ensure destination directory exists
      file:
        path: /opt/itadmin
        state: directory
        mode: '0755'

    - name: Copy files to respective servers using loops and when
      copy:
        src: "/usr/src/itadmin/{{ item.filename }}"
        dest: "/opt/itadmin/{{ item.filename }}"
        owner: "{{ item.owner }}"
        group: "{{ item.owner }}"
        mode: '0744'
      when: ansible_nodename == item.target_host
      loop:
        - { target_host: 'stapp01', filename: 'blog.txt', owner: 'tony' }
        - { target_host: 'stapp02', filename: 'story.txt', owner: 'steve' }
        - { target_host: 'stapp03', filename: 'media.txt', owner: 'banner' }
```

### 3. Execution and Verification
The playbook was executed from the working directory using the following command:

```bash
ansible-playbook -i inventory playbook.yml
```

**Verification Results:**
* On `stapp01`, the `blog.txt` was copied while other items were skipped.
* On `stapp02`, the `story.txt` was copied while other items were skipped.
* On `stapp03`, the `media.txt` was copied while other items were skipped.
* All files were verified to have `0744` permissions and correct ownership.