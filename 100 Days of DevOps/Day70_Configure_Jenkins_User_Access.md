# Nautilus DevOps Task: Day 70 - Configure Jenkins User Access

## Objective
The Nautilus team needs to configure granular user access for their development team on a newly provisioned Jenkins server. The task involves creating a new user, implementing the Project-based Matrix Authorization Strategy, securing the `admin` account, removing `Anonymous` access, and setting specific job-level permissions.

## Prerequisites
* Access to the Jenkins Web UI.
* Admin credentials: `admin` / `Adm!n321`.

---

## Execution Steps

### Step 1: Install the Matrix Authorization Plugin
By default, Jenkins does not include the Project-based Matrix Authorization Strategy. It must be installed via the plugin manager.

1. Log into Jenkins using the `admin` credentials.
2. Navigate to **Manage Jenkins** (⚙️) -> **Plugins**.
3. Click on the **Available plugins** tab.
4. Search for `Matrix Authorization Strategy`.
5. Check the box next to **Matrix Authorization Strategy Plugin** and click **Install**.
6. Check the box for **Restart Jenkins when installation is complete and no jobs are running**. 
7. Wait for Jenkins to reboot and log back in.

### Step 2: Create the New User
1. From the dashboard, navigate to **Manage Jenkins** -> **Users** (under the Security section).
2. Click on **Create User**.
3. Fill in the required details:
   * **Username:** `yousuf`
   * **Password:** `ksH85UJjhb`
   * **Confirm password:** `ksH85UJjhb`
   * **Full name:** `Yousuf`
4. Click **Create User**.

### Step 3: Configure Global Security (Matrix Authorization)
> ⚠️ **CRITICAL WARNING:** When configuring matrix security, always explicitly grant the `admin` user full `Administer` permissions **before** saving. Failing to do so will permanently lock you out of the Jenkins instance!

1. Navigate to **Manage Jenkins** -> **Security**.
2. Scroll down to the **Authorization** section and select **Project-based Matrix Authorization Strategy**.
3. **Secure the Admin:** * Click **Add user or group...**, type `admin`, and click **OK**.
   * In the matrix row for `admin`, check the box under **Overall -> Administer** (or use the check-all icon at the far right of the row).
4. **Configure the New User:** * Click **Add user or group...**, type `yousuf`, and click **OK**.
   * In the matrix row for `yousuf`, check **ONLY** the box under **Overall -> Read**.
5. **Remove Anonymous Access:** * Locate the row for `Anonymous` and ensure **every single box is unchecked**.
6. Scroll to the bottom and click **Save**.

### Step 4: Configure Job-Level Permissions
The user `yousuf` now has global read access, but needs specific read permissions for the existing job without access to Agent, SCM, etc.

1. Return to the main Jenkins dashboard.
2. Click on the name of the **existing job** listed on the dashboard.
3. Click **Configure** on the left-hand menu.
4. In the **General** tab, check the box for **Enable project-based security**.
5. A job-specific matrix table will appear.
6. Click **Add user or group...**, type `yousuf`, and click **OK**.
7. In the row for `yousuf`, look under the **Job** (or **Item**) section and check **ONLY** the **Read** box. Ensure all other permissions (Agent, SCM, Run, etc.) remain unchecked.
8. Scroll to the bottom and click **Save**.

---

## Verification & Documentation
1. Verify that navigating the dashboard as `admin` still provides full access to Manage Jenkins.
2. Capture screenshots of:
   * The **Global Security Matrix** showing the `admin`, `yousuf`, and `Anonymous` configurations.
   * The **Job-Level Security Matrix** inside the existing job's configuration page.
3. Submit screenshots for task review.