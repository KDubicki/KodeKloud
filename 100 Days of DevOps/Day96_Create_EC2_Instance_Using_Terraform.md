# Nautilus DevOps Task: Day 96 - Create EC2 Instance Using Terraform

## Objective
As part of the phased AWS migration strategy, the Nautilus DevOps team requires the automated provisioning of an Amazon EC2 instance. This task involves utilizing Infrastructure as Code (Terraform) to spin up a specific instance type, generate and attach a new SSH key pair, and apply standard security groupings and tags.

## Environment Details
* **Cloud Provider:** AWS
* **Working Directory:** `/home/bob/terraform`
* **Resource to Create:** AWS EC2 Instance (`aws_instance`) & Key Pair (`aws_key_pair`)
* **Instance Tag (Name):** `devops-ec2`
* **Amazon Machine Image (AMI):** `ami-0c101f26f147fa7fd` (Amazon Linux)
* **Instance Type:** `t2.micro`
* **Key Pair Name:** `devops-kp`
* **Security Group:** `default`

---

## Editor & Terminal Shortcuts (VS Code)
Use the following shortcuts to open the integrated terminal in VS Code:
* **MacOS:** `^ + \`` (Control + Backtick)
* **Windows/Linux:** `Ctrl + Shift + \``

## Execution Steps

### 1. Create the Terraform Configuration File
Created the `main.tf` file within the `/home/bob/terraform` directory. To fully automate the key pair creation process without relying on pre-existing local keys, the `tls_private_key` resource was utilized to generate an RSA key dynamically, which was then passed to the `aws_key_pair` resource. The EC2 instance was then configured to use this key and the default security group.

```hcl
# main.tf

# Generate an RSA private key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS Key Pair using the generated public key
resource "aws_key_pair" "devops_kp" {
  key_name   = "devops-kp"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# Provision the EC2 Instance
resource "aws_instance" "devops_ec2" {
  ami             = "ami-0c101f26f147fa7fd"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.devops_kp.key_name
  security_groups = ["default"]

  tags = {
    Name = "devops-ec2"
  }
}
```

### 2. Initialize Terraform
Initialized the working directory. This downloaded both the `hashicorp/aws` and `hashicorp/tls` providers required for the deployment.

```bash
terraform init
```

### 3. Review the Execution Plan
Generated an execution plan to verify the creation of the private key, the key pair, and the EC2 instance before applying.

```bash
terraform plan
```

### 4. Apply the Infrastructure Changes
Applied the configuration to provision the resources in the AWS account.

```bash
terraform apply -auto-approve
```

**Verification:**
The terminal output confirmed the successful creation of all resources:
`Apply complete! Resources: 3 added, 0 changed, 0 destroyed.`
The instance was successfully deployed with the requested AMI, size, key pair, and name tag.