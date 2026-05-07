# Fork a Git Repository

## Objective
To simulate onboarding a new developer to the Nautilus project teams, this task requires accessing the internal Git server (Gitea) via its web interface to fork an existing central repository into the new developer's personal workspace. Forking allows developers to freely experiment and commit changes without affecting the original project until a pull request is made.

## Environment Details
* **Git Server:** Gitea (Internal Web UI)
* **User Account:** `jon`
* **Target Repository:** `sarah/story-blog`
* **Action Required:** UI-based Repository Fork

---

## Execution Steps

### 1. Access the Git Web Interface
Accessed the internal Gitea web application through the provided laboratory UI portal.

### 2. Authenticate
Logged into the Gitea platform using the new developer's credentials:
* **Username:** `jon`
* **Password:** `[REDACTED]`

### 3. Locate the Target Repository
Utilized the Gitea repository explorer/search function to navigate to the source repository maintained by the project lead: `sarah/story-blog`.

### 4. Fork the Repository
Initiated the repository fork process:
1. Clicked the **Fork** button located in the top-right corner of the repository dashboard.
2. Verified that the target owner for the new fork was set to the `jon` workspace.
3. Confirmed the action, resulting in the successful creation of a detached, independent copy of the repository located at `jon/story-blog`.

### 5. Verification
Verified the successful fork by confirming that the `jon/story-blog` repository was successfully created, populated with the original source code, and listed under the developer's personal dashboard.