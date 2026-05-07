# Clone Git Repository on Storage Server

## Objective
The Nautilus application development team requested a working copy of a recently established, unused Git repository. The objective is to clone this existing local bare repository to a specific directory on the Storage Server within the Stratos DC. This must be executed strictly using the designated user account (`natasha`) to ensure the resulting cloned directory inherits the correct ownership and permissions without requiring unauthorized alterations.

## Environment Details
* **Target Server:** Storage Server (`ststor01`)
* **User:** `natasha`
* **Source Repository:** `/opt/demo.git`
* **Target Parent Directory:** `/usr/src/kodekloudrepos`
* **Expected Repository Directory:** `/usr/src/kodekloudrepos/demo`

---

## Execution Steps

### 1. Connect to the Target Server
Established an SSH connection to the Storage Server from the Jump Host using the infrastructure credentials.

```bash
ssh natasha@ststor01
```

### 2. Navigate to the Target Directory
Navigated directly to the target parent directory. This strategy ensures that Git automatically creates the designated repository folder (`demo`) with the correct inherited user permissions natively, avoiding directory structure mismatch errors.

```bash
cd /usr/src/kodekloudrepos
```

### 3. Clone the Local Repository
Utilized the `git clone` command to create a working copy of the repository. In Git, cloning a local repository path operates similarly to cloning from a remote URL. 

```bash
git clone /opt/demo.git
```

**Verification:**
The terminal output confirmed the successful cloning process:
```text
Cloning into 'demo'...
warning: You appear to have cloned an empty repository.
done.
```
*(Note: The "empty repository" warning is expected and confirms success, as the source bare repository contained no initial commits.)*