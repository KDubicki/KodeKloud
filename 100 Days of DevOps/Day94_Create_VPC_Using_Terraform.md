# Nautilus DevOps Task: Day 94 - Create VPC Using Terraform

## Objective
The Nautilus DevOps team is beginning the migration of their infrastructure to the AWS cloud in a granular, phased approach. The first foundational step is to provision an Amazon Virtual Private Cloud (VPC) using Terraform as the Infrastructure as Code (IaC) tool. 

## Environment Details
* **Cloud Provider:** AWS
* **Region:** `us-east-1`
* **VPC Name:** `datacenter-vpc`
* **CIDR Block:** `10.0.0.0/16` (Standard IPv4 Block)
* **Working Directory:** `/home/bob/terraform`
* **File to Create:** `main.tf`

---

## Editor & Terminal Shortcuts (VS Code)
Depending on your operating system, use the following shortcuts to open the integrated terminal in VS Code to execute Terraform commands:
* **MacOS:** `^ + \`` (Control + Backtick)
* **Windows/Linux:** `Ctrl + Shift + \``

## Execution Steps

### 1. Create the Terraform Configuration File
In the specified working directory (`/home/bob/terraform`), a `provider.tf` was already present. A new `main.tf` file was created to define the VPC resource. 

The `aws_vpc` resource block was utilized. In AWS, the "name" of a VPC is assigned via a Tag with the key `Name`.

```hcl
# main.tf
resource "aws_vpc" "datacenter_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "datacenter-vpc"
  }
}
```

*Alternatively, this can be created via terminal:*
```bash
cat << 'EOF' > main.tf
resource "aws_vpc" "datacenter_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "datacenter-vpc"
  }
}
EOF
```

### 2. Initialize Terraform
Before executing any infrastructure deployment, the working directory must be initialized. This downloads the necessary AWS provider plugins required to interact with the AWS API.

```bash
terraform init
```

### 3. Review the Execution Plan
It is a best practice to generate an execution plan to preview the changes Terraform will make to the infrastructure.

```bash
terraform plan
```
*(Expected output: Terraform will indicate that `1 to add, 0 to change, 0 to destroy`, showing the details of the `datacenter-vpc`)*.

### 4. Apply the Infrastructure Changes
Applied the configuration to provision the VPC in the AWS account. The `-auto-approve` flag was used to bypass the interactive confirmation prompt.

```bash
terraform apply -auto-approve
```

**Verification:**
The terminal output confirmed the successful creation of the resource:
`Apply complete! Resources: 1 added, 0 changed, 0 destroyed.`