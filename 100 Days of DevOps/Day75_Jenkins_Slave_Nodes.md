# Nautilus DevOps Task: Day 75 - Jenkins Slave Nodes

## Objective
To scale the CI/CD environment and distribute workloads, the Nautilus DevOps team requires all three App Servers to be configured as SSH build agents (slave nodes) within Jenkins. Each node must be configured with specific labels, remote root directories, and compatible Java environments.

## Prerequisites
* Jenkins Web UI access: `admin` / `Adm!n321`
* App Server 1 (`stapp01`) credentials: `tony` / `Ir0nM@n`
* App Server 2 (`stapp02`) credentials: `steve` / `Am3ric@`
* App Server 3 (`stapp03`) credentials: `banner` / `BigGr33n`

---

## Execution Steps

### 1. Install the SSH Build Agents Plugin
By default, the required plugin to launch agents over SSH might be missing.
1. Log into the Jenkins UI.
2. Navigate to **Manage Jenkins** -> **Plugins** -> **Available plugins**.
3. Search for **SSH Build Agents**.
4. Check the box, click **Install**, and select the option to restart Jenkins after installation.

### 2. Configure Global Credentials
1. Navigate to **Manage Jenkins** -> **Credentials** -> **System** -> **Global credentials (unrestricted)**.
2. Click **Add Credentials** to add three separate `Username with password` credentials:
   * **App Server 1:** Username: `tony`, Password: `Ir0nM@n`, ID: `stapp01-cred`
   * **App Server 2:** Username: `steve`, Password: `Am3ric@`, ID: `stapp02-cred`
   * **App Server 3:** Username: `banner`, Password: `BigGr33n`, ID: `stapp03-cred`

### 3. Troubleshoot & Update Java Environment (Crucial Step)
*Issue:* Jenkins Controller runs on Java 17, while the App Servers default to Java 11. This causes a `java.lang.UnsupportedClassVersionError` during the agent launch.
*Fix:* Update Java to version 17 on all App Servers before connecting them.

From the Jump Host terminal, execute the following commands:
```bash
# Update Java on App Server 1
ssh tony@stapp01 "echo 'Ir0nM@n' | sudo -S yum install -y java-17-openjdk"

# Update Java on App Server 2
ssh steve@stapp02 "echo 'Am3ric@' | sudo -S yum install -y java-17-openjdk"

# Update Java on App Server 3
ssh banner@stapp03 "echo 'BigGr33n' | sudo -S yum install -y java-17-openjdk"
```

### 4. Configure the Slave Nodes (Agents)
1. Navigate to **Manage Jenkins** -> **Nodes**.
2. For each server, click **New Node**, enter the exact Node Name, select **Permanent Agent**, and click **Create**.
3. Configure the nodes using the matrix below:

#### Node 1: App_server_1
* **Remote root directory:** `/home/tony/jenkins`
* **Labels:** `stapp01`
* **Launch method:** `Launch agents via SSH`
* **Host:** `stapp01`
* **Credentials:** Select `tony`
* **Host Key Verification Strategy:** `Non-verifying Verification Strategy`

#### Node 2: App_server_2
* **Remote root directory:** `/home/steve/jenkins`
* **Labels:** `stapp02`
* **Launch method:** `Launch agents via SSH`
* **Host:** `stapp02`
* **Credentials:** Select `steve`
* **Host Key Verification Strategy:** `Non-verifying Verification Strategy`

#### Node 3: App_server_3
* **Remote root directory:** `/home/banner/jenkins`
* **Labels:** `stapp03`
* **Launch method:** `Launch agents via SSH`
* **Host:** `stapp03`
* **Credentials:** Select `banner`
* **Host Key Verification Strategy:** `Non-verifying Verification Strategy`

### 5. Verification
1. Return to the **Nodes** dashboard.
2. If a node shows as offline, click on the node name and select **Launch agent** to force a connection attempt.
3. Review the node logs to ensure the output reads: `Agent successfully connected and online`.
4. All three nodes should now appear online in the dashboard without any red error icons.