# Nautilus DevOps Task: Day 95 - Create Security Group Using Terraform

## Objective
Continuing the phased migration to the AWS cloud, the Nautilus DevOps team requires the provisioning of a Security Group within the default VPC. This Security Group acts as a virtual firewall for the Nautilus Application Servers, specifically allowing inbound HTTP and SSH traffic from any IP address.

## Environment Details
* **Cloud Provider:** AWS
* **Region:** `us-east-1`
* **Working Directory:** `/home/bob/terraform`
* **Resource to Create:** AWS Security Group (`aws_security_group`)
* **Security Group Name:** `nautilus-sg`
* **Description:** `Security group for Nautilus App Servers`

**Inbound (Ingress) Rules:**
1. **Type:** HTTP | **Port:** 80 | **Protocol:** TCP | **Source:** `0.0.0.0/0`
2. **Type:** SSH | **Port:** 22 | **Protocol:** TCP | **Source:** `0.0.0.0/0`

---

## Editor & Terminal Shortcuts (VS Code)
Use the following shortcuts to quickly open the integrated terminal in VS Code:
* **MacOS:** `^ + \`` (Control + Backtick)
* **Windows/Linux:** `Ctrl + Shift + \``

## Execution Steps

### 1. Create the Terraform Configuration File
Created the `main.tf` file within the `/home/bob/terraform` directory. The `vpc_id` attribute was intentionally omitted so that AWS provisions the Security Group in the default VPC, satisfying the task constraints. 

*Note: An `egress` block was included to allow all outbound traffic (`protocol = "-1"`). Unlike the AWS Management Console, Terraform removes all default outbound rules if the `egress` block is not explicitly defined.*

```hcl
# main.tf
resource "aws_security_group" "nautilus_sg" {
  name        = "nautilus-sg"
  description = "Security group for Nautilus App Servers"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 2. Initialize Terraform
Initialized the working directory to download the necessary AWS provider plugins.

```bash
terraform init
```

### 3. Review the Execution Plan
Generated an execution plan to verify the security group and its associated ingress/egress rules before deployment.

```bash
terraform plan
```

### 4. Apply the Infrastructure Changes
Applied the configuration to provision the security group in the AWS account.

```bash
terraform apply -auto-approve
```

**Verification:**
The terminal output confirmed the successful creation of the resource:
`Apply complete! Resources: 1 added, 0 changed, 0 destroyed.`