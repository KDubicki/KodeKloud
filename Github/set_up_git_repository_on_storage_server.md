# Create a Bare Git Repository

## Objective
The Nautilus development team requested the establishment of a centralized Git repository for a new application development project. The objective is to install Git and provision a "bare" repository on the designated Storage Server within the Stratos DC. A bare repository acts as a central sharing point for developers to push and pull code, without maintaining a local working tree.

## Environment Details
* **Target Server:** Storage Server (`ststor01`)
* **User:** `natasha`
* **Package Manager:** `yum`
* **Repository Path:** `/opt/official.git`
* **Repository Type:** Bare

---

## Execution Steps

### 1. Connect to the Target Server
Logged into the Storage Server from the Jump Host via SSH.

```bash
ssh natasha@ststor01
# Authenticated using the provided infrastructure credentials
```

### 2. Install the Git Package
Utilized the `yum` package manager with elevated privileges to install the Git software suite. The `-y` flag was used to automatically approve the installation prompts.

```bash
sudo yum install -y git
```

### 3. Initialize the Bare Repository
Created the centralized repository in the `/opt` directory using the `git init` command with the `--bare` flag. This ensures the repository is configured strictly for remote tracking and sharing, not for direct file editing.

```bash
sudo git init --bare /opt/official.git
```

**Verification:**
The system output confirmed the successful initialization:
`Initialized empty Git repository in /opt/official.git/`