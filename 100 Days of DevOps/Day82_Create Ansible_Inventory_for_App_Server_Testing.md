# Nautilus DevOps Task: Day 82 - Create Ansible Inventory for App Server Testing

## Objective
The DevOps team requires an Ansible inventory file to test playbooks specifically on `App Server 1` in the Stratos Datacenter. The inventory must be in INI format, located at `/home/thor/playbook/inventory`, and contain all necessary variables so that the command `ansible-playbook -i inventory playbook.yml` executes smoothly without requesting additional arguments or SSH passwords.

## Environment Details
* **Jump Host User:** `thor`
* **Target Server:** App Server 1 (`stapp01`)
* **Target User:** `tony`
* **Target Password:** `Ir0nM@n`
* **Inventory Location:** `/home/thor/playbook/inventory`

---

## Execution Steps

### 1. Navigate to the Playbook Directory
Connected to the `jump_host` as the user `thor`, navigate to the designated playbook directory:
```bash
cd /home/thor/playbook/
```

### 2. Create the INI Inventory File
Created an INI-formatted `inventory` file. To ensure the playbook runs without requiring manual password input (`--ask-pass`), Ansible's behavioral inventory variables (`ansible_user` and `ansible_ssh_pass`) were explicitly defined for the host `stapp01`.

```bash
cat << 'EOF' > inventory
stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n
EOF
```

### 3. Verification
Executed an ad-hoc Ansible `ping` command to verify connectivity and authentication using the newly created inventory file:
```bash
ansible -i inventory stapp01 -m ping
```

**Expected Output:**
```json
stapp01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

This confirms the inventory file is correctly formatted and the credentials are valid for `App Server 1`.