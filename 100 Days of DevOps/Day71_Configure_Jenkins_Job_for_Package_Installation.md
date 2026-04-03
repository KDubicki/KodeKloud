# Nautilus DevOps Task: Day 71 - Configure Jenkins Job for Package Installation

## Objective
Automate the installation of packages on the Stratos Datacenter storage server (`ststor01`) by creating a parameterized Jenkins job named `install-packages`. This solution uses the Jenkins UI and the SSH plugin for secure remote execution.

## Prerequisites
* Access to the Jenkins Web UI.
* Admin credentials: `admin` / `Adm!n321`
* Storage Server (`ststor01`) credentials: `natasha` / `Bl@kW`

---

## Execution Steps

### 1. Install Required Plugins
1. Navigate to **Manage Jenkins** (⚙️) -> **Plugins** -> **Available plugins**.
2. Search for the **SSH** plugin and check the box next to it.
3. Click **Install** and check the box to **Restart Jenkins when installation is complete and no jobs are running**.

### 2. Configure Global Credentials
1. After Jenkins restarts, navigate to **Manage Jenkins** -> **Credentials** -> **System** -> **Global credentials (unrestricted)**.
2. Click **Add Credentials**:
   * **Kind:** Username with password
   * **Username:** `natasha`
   * **Password:** `Bl@kW`
   * **ID:** `ststor01-cred`
3. Click **Create**.

### 3. Add SSH Remote Host
1. Navigate to **Manage Jenkins** -> **System**.
2. Scroll down to the **SSH remote hosts** section and click **Add**:
   * **Hostname:** `ststor01`
   * **Port:** `22`
   * **Credentials:** Select the `natasha` credential created in the previous step.
3. Click **Check connection** to ensure connectivity (it should display "Success"), then scroll to the bottom and click **Save**.
   *(Note: If the connection initially fails due to Host Key Verification, open a terminal on the Jenkins server, run `ssh natasha@ststor01`, type `yes` to accept the fingerprint, and then retry the connection check in the UI).*

### 4. Create the Parameterized Job
1. From the main dashboard, click **New Item**, name it `install-packages`, and select **Freestyle project**.
2. Under the General section, check **This project is parameterized** and add a **String Parameter**:
   * **Name:** `PACKAGE`
   * **Default Value:** `vim-enhanced`
3. Scroll down to **Build Steps**, click **Add build step**, and select **Execute shell script on remote host using ssh**.
4. In the **SSH site** dropdown, select `natasha@ststor01:22`.
5. In the **Command** text box, enter the exact command below to pass the password to `sudo` non-interactively and install the package:
   ```bash
   echo 'Bl@kW' | sudo -S yum install -y $PACKAGE