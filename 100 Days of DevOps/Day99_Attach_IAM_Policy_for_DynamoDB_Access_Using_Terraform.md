# Nautilus DevOps Task: Day 99 - Attach IAM Policy for DynamoDB Access Using Terraform

## Objective
The Nautilus DevOps team requires the provisioning of a secure AWS DynamoDB table accompanied by strict Identity and Access Management (IAM) controls. The goal is to enforce fine-grained access, adhering to the principle of least privilege, by creating a role and a read-only policy that grants access (`GetItem`, `Scan`, `Query`) exclusively to the newly created DynamoDB table. The solution is fully parameterized using Terraform best practices.

## Environment Details
* **Cloud Provider:** AWS
* **Working Directory:** `/home/bob/terraform`
* **DynamoDB Table Name:** `xfusion-table`
* **IAM Role Name:** `xfusion-role`
* **IAM Policy Name:** `xfusion-readonly-policy`

---

## Execution Steps

### 1. Define Variables (`variables.tf`)
Created the `variables.tf` file to parameterize the names of the resources as requested.

```hcl
# variables.tf
variable "KKE_TABLE_NAME" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "KKE_ROLE_NAME" {
  description = "Name of the IAM role"
  type        = string
}

variable "KKE_POLICY_NAME" {
  description = "Name of the IAM policy"
  type        = string
}
```

### 2. Inject Values (`terraform.tfvars`)
Created the `.tfvars` file to supply the actual string values for the variables during execution.

```hcl
# terraform.tfvars
KKE_TABLE_NAME  = "xfusion-table"
KKE_ROLE_NAME   = "xfusion-role"
KKE_POLICY_NAME = "xfusion-readonly-policy"
```

### 3. Define Outputs (`outputs.tf`)
Configured the `outputs.tf` file to dynamically extract the provisioned resource names.

```hcl
# outputs.tf
output "kke_dynamodb_table" {
  value = aws_dynamodb_table.xfusion_table.name
}

output "kke_iam_role_name" {
  value = aws_iam_role.xfusion_role.name
}

output "kke_iam_policy_name" {
  value = aws_iam_policy.xfusion_policy.name
}
```

### 4. Build Main Infrastructure (`main.tf`)
Created the `main.tf` file to provision the NoSQL table, IAM Role, and the IAM Policy. The policy ensures fine-grained access control by dynamically referencing the `arn` (Amazon Resource Name) of the table, rather than granting access to all DynamoDB resources.

```hcl
# main.tf

# 1. DynamoDB Table Definition
resource "aws_dynamodb_table" "xfusion_table" {
  name         = var.KKE_TABLE_NAME
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# 2. IAM Role Definition
resource "aws_iam_role" "xfusion_role" {
  name = var.KKE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Read-Only IAM Policy
resource "aws_iam_policy" "xfusion_policy" {
  name = var.KKE_POLICY_NAME

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.xfusion_table.arn
      }
    ]
  })
}

# 4. Attach Policy to Role
resource "aws_iam_role_policy_attachment" "xfusion_attach" {
  role       = aws_iam_role.xfusion_role.name
  policy_arn = aws_iam_policy.xfusion_policy.arn
}
```

### 5. Initialization and Deployment
Executed the Terraform workflow to securely provision the table and its associated access management objects.

```bash
terraform init
terraform apply -auto-approve
```

### 6. Final Validation
Executed a final plan command to ensure the state perfectly matched the configuration.

```bash
terraform plan
# Expected Output: "No changes. Your infrastructure matches the configuration."
```