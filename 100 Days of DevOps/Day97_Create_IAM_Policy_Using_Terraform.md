# Nautilus DevOps Task: Day 97 - Create IAM Policy Using Terraform

## Objective
As the Nautilus DevOps team continues its phased infrastructure migration to AWS, securing access via Identity and Access Management (IAM) is critical. The objective of this task is to use Terraform to provision an IAM Policy that grants read-only access to the EC2 console, allowing users to view all EC2 instances, AMIs, and snapshots without the ability to modify or delete them.

## Environment Details
* **Cloud Provider:** AWS
* **Region:** `us-east-1`
* **Working Directory:** `/home/bob/terraform`
* **Resource to Create:** AWS IAM Policy (`aws_iam_policy`)
* **Policy Name:** `iampolicy_siva`
* **Access Level:** Read-only (`ec2:Describe*`)

---

## Editor & Terminal Shortcuts (VS Code)
Use the following shortcuts to open the integrated terminal in VS Code:
* **MacOS:** `^ + \`` (Control + Backtick)
* **Windows/Linux:** `Ctrl + Shift + \``

## Execution Steps

### 1. Create the Terraform Configuration File
Created the `main.tf` file within the `/home/bob/terraform` directory. The `aws_iam_policy` resource was defined, and the policy document was structured using Terraform's built-in `jsonencode()` function for cleaner syntax and robust JSON generation. The action `ec2:Describe*` on `Resource = "*"` effectively grants the required read-only permissions for the EC2 console.

```hcl
# main.tf

resource "aws_iam_policy" "iampolicy_siva" {
  name        = "iampolicy_siva"
  description = "Allows read-only access to the EC2 console (instances, AMIs, snapshots)"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
```

*Terminal command to generate the file:*
```bash
cat << 'EOF' > main.tf
resource "aws_iam_policy" "iampolicy_siva" {
  name        = "iampolicy_siva"
  description = "Allows read-only access to the EC2 console"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
EOF
```

### 2. Initialize Terraform
Initialized the working directory to download the AWS provider plugins.

```bash
terraform init
```

### 3. Review the Execution Plan
Generated an execution plan to verify the correct formatting of the IAM policy JSON and confirm the creation of the resource.

```bash
terraform plan
```

### 4. Apply the Infrastructure Changes
Applied the configuration to provision the IAM policy in the AWS account.

```bash
terraform apply -auto-approve
```

**Verification:**
The terminal output confirmed the successful creation of the IAM policy:
`Apply complete! Resources: 1 added, 0 changed, 0 destroyed.`
The policy `iampolicy_siva` is now available in the AWS account to be attached to roles, users, or groups.