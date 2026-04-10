# Nautilus DevOps Task: Day 76 - Jenkins Project Security

## Objective
The development team requires selective access for two new developers (`sam` and `rohan`) to an existing Jenkins job named `Packages`. The task involves transitioning Jenkins to a Project-based Matrix Authorization Strategy and granting granular project-level permissions without altering the existing job configuration.

## Prerequisites
* Jenkins Web UI access: `admin` / `Adm!n321`
* Existing users: `sam` and `rohan`
* Existing job: `Packages`

---

## Execution Steps

### 1. Install Authorization Plugin
By default, Jenkins requires a specific plugin to enable granular, matrix-based security.
1. Log into the Jenkins UI.
2. Navigate to **Manage Jenkins** -> **Plugins** -> **Available plugins**.
3. Search for the **Matrix Authorization Strategy** plugin.
4. Install the plugin and restart Jenkins.

### 2. Configure Global Security
Before applying project-level security, the global authorization strategy must be updated. *Warning: The admin user must be explicitly granted full permissions during this step to prevent lockout.*

1. Navigate to **Manage Jenkins** -> **Security**.
2. Under the **Authorization** section, select **Project-based Matrix Authorization Strategy**.
3. Add the following users to the matrix: `admin`, `sam`, `rohan`.
4. Apply the following Global Permissions:
   * **`admin`**: Check `Overall -> Administer` (grants full access).
   * **`sam`**: Check `Overall -> Read` (allows UI access).
   * **`rohan`**: Check `Overall -> Read` (allows UI access).
5. Click **Save**.

### 3. Apply Project-Based Security
1. From the Jenkins Dashboard, open the **Packages** job and click **Configure**.
2. Under the General section, check the box for **Enable project-based security**.
3. Set the **Inheritance Strategy** to: `Inherit permissions from parent ACL`.
4. Add the users `sam` and `rohan` to the project matrix.
5. Grant the specific project-level permissions:
   * **User `sam`:**
     * Job: `Build`, `Configure`, `Read`
   * **User `rohan`:**
     * Job: `Build`, `Cancel`, `Configure`, `Read`
     * Run: `Update`
     * SCM: `Tag`
6. Click **Save** to apply the security matrix.

### 4. Verification
1. To verify, log out of the `admin` account.
2. Log in as `sam` (`sam@pass12345`) and verify visibility and access rights to the `Packages` job (no cancel/update/tag rights).
3. Log out and log in as `rohan` (`rohan@pass12345`) to verify their extended permission set.