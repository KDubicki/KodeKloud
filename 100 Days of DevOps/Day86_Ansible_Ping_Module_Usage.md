# Nautilus DevOps Task: Day 86 - Ansible Ping Module Usage

## Objective
The Nautilus DevOps team is transitioning to secure, password-less authentication for their automation pipelines. The objective of this task is to establish a password-less SSH connection utilizing public key authentication between the Ansible controller (`jump_host`) and a managed node (`App Server 2`), and subsequently verify the connection using the Ansible `ping` module.

## Environment Details
* **Control Node:** `jump_host` (User: `thor`)
* **Managed Node:** App Server 2 / `stapp02` (Target User: `steve`)
* **Inventory File:** `/home/thor/ansible/inventory`

---

## Execution Steps

### 1. Generate SSH Key Pair on Control Node
Executed the `ssh-keygen` utility on the `jump_host` as the `thor` user to generate a standard RSA key pair. No passphrase was provided (`-N ""`) to allow for seamless, automated authentication by Ansible.

```bash
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
```

### 2. Distribute Public Key to Managed Node
Used the `ssh-copy-id` tool to securely append the newly generated public key to the `authorized_keys` file of the `steve` user on `App Server 2` (`stapp02`). 

```bash
ssh-copy-id steve@stapp02
```
*(Note: Manual intervention was required once to accept the host fingerprint and input the initial SSH password for user `steve` (`Am3ric@`) to complete the transfer).*

### 3. Update Inventory Configuration
To ensure Ansible automatically authenticates as the correct user without requiring the explicit `-u steve` flag (which is critical for automated CI/CD validations), the target user was mapped directly inside the inventory file.

```bash
echo "stapp02 ansible_user=steve" > /home/thor/ansible/inventory
```

### 4. Verify Connection with Ansible Ping
Executed an ad-hoc Ansible command utilizing the `ping` module to verify that the Ansible controller could successfully reach and authenticate against the managed node using the updated inventory file.

```bash
ansible stapp02 -m ping -i /home/thor/ansible/inventory
```

**Expected Output:**
```json
stapp02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```
The response `"ping": "pong"` confirms that the password-less SSH trust was correctly established, the inventory is properly configured, and Ansible can successfully manage the target node autonomously.