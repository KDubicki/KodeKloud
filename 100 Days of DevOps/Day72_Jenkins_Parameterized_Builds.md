# Nautilus DevOps Task: Day 72 - Jenkins Parameterized Builds

## Objective
The Nautilus DevOps team requires a simple parameterized Jenkins job to test and demonstrate basic parameter functionality for new team members. The task involves creating a job named `parameterized-job` with both String and Choice parameters, and echoing those variables in a shell execution step.

## Prerequisites
* Access to the Jenkins Web UI.
* Admin credentials: `admin` / `Adm!n321`

---

## Execution Steps

### 1. Create the Jenkins Job
1. Log into the Jenkins UI.
2. From the main dashboard, click on **New Item**.
3. Enter `parameterized-job` as the item name.
4. Select **Freestyle project** and click **OK**.

### 2. Configure Parameters
1. Under the **General** tab, check the box labeled **This project is parameterized**.
2. **Add a String Parameter:**
   * Click **Add Parameter** -> **String Parameter**.
   * **Name:** `Stage`
   * **Default Value:** `Build`
3. **Add a Choice Parameter:**
   * Click **Add Parameter** -> **Choice Parameter**.
   * **Name:** `env`
   * **Choices:** (Enter each choice on a new line)
     ```text
     Development
     Staging
     Production
     ```

### 3. Add Build Steps
1. Scroll down to the **Build Steps** section.
2. Click **Add build step** and select **Execute shell**.
3. In the **Command** text box, enter the following script to echo the parameters:
   ```bash
   echo "Executing Stage: $Stage"
   echo "Target Environment: $env"