# Nautilus DevOps Task: Day 69 - Install Jenkins Plugins

## Objective
The Nautilus DevOps team requires specific plugins to be installed on an existing Jenkins server to support upcoming CI/CD jobs. The task involves installing the `Git` and `GitLab` plugins and ensuring they are active.

## Prerequisites
* Access to the Jenkins Web UI.
* Admin credentials: `admin` / `Adm!n321`.

---

## Execution Steps

### 1. Log into Jenkins
1. Open the Jenkins UI in your web browser.
2. Log in using the provided `admin` credentials.

### 2. Navigate to the Plugin Manager
1. From the main dashboard, click on the **Gear icon (⚙️) Manage Jenkins** located in the top right corner.
2. Scroll down to the *System Configuration* section and click on **Plugins**.

### 3. Select Plugins for Installation
1. Click on the **Available plugins** tab on the left sidebar.
2. In the search bar, type `Git`. Locate the **Git** plugin in the list and check the box next to it.
3. Clear the search bar and type `GitLab`. Locate the **GitLab** plugin and check the box.
4. Click the **Install** button at the bottom of the page.

### 4. Handle Installation & Restart
1. On the download progress page, check the box that says: **Restart Jenkins when installation is complete and no jobs are running**.
2. Wait for Jenkins to download the plugins and restart automatically.

---

## Troubleshooting: Plugin Dependency Failures

**Issue:** During the installation process, the plugins may fail to install, throwing a `java.io.IOException`. The logs will indicate that underlying dependencies (like the `Credentials Plugin` or `Git client plugin`) failed to load. 

**Root Cause:** Jenkins refused to dynamically load updates to core security components while the server is actively running. It downloads them but requires a hard reboot to apply them before the dependent `Git` plugin can be installed.

**Resolution:**
1. **Force a manual restart:** Append `/restart` to the end of the Jenkins URL in your browser (e.g., `http://<jenkins-server-ip>:8080/restart`) and hit **Enter**. 
2. Click **Yes** to confirm the restart.
3. Wait for Jenkins to reboot and log back in.
4. The restart typically resolves and completes the pending installations of the locked dependencies. 
5. *(Optional)* If the Git and GitLab plugins did not finish installing during the reboot, return to **Available plugins** and retry the installation. It will now succeed because the core dependencies are fully updated.

---

## Verification
1. Navigate to **Manage Jenkins** ⚙️ -> **Plugins** -> **Installed plugins**.
2. Search for `Git` and `GitLab`.
3. Verify that the `Git plugin`, `Git client plugin`, and `GitLab Plugin` are all listed with their toggle switches in the enabled state.
4. Take screenshots of the installed plugins page for task validation.