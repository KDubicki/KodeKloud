# Nautilus DevOps Task: Day 98 - Launch EC2 in Private VPC Subnet Using Terraform

## Objective
The Nautilus DevOps team is expanding their AWS footprint by establishing an isolated, private network environment. The goal is to provision a Virtual Private Cloud (VPC), a private subnet, and deploy an EC2 instance that is accessible exclusively from within the VPC. This ensures strict internal communication and heightened security. The configuration uses standard Terraform modularity practices, separating configurations into `variables.tf`, `main.tf`, and `outputs.tf`.

## Environment Details
* **Cloud Provider:** AWS
* **Working Directory:** `/home/bob/terraform`
* **VPC Name:** `xfusion-priv-vpc` (CIDR: `10.0.0.0/16`)
* **Subnet Name:** `xfusion-priv-subnet` (CIDR: `10.0.1.0/24`, Auto-assign IP: `Disabled`)
* **EC2 Instance Name:** `xfusion-priv-ec2` (Type: `t2.micro`)
* **Security Group:** Restricted to VPC CIDR (`10.0.0.0/16`) internal traffic only.

---

## Execution Steps

### 1. Define Variables (`variables.tf`)
Created the `variables.tf` file to parameterize the network CIDR blocks as requested by the task requirements (`KKE_VPC_CIDR` and `KKE_SUBNET_CIDR`).

```hcl
# variables.tf
variable "KKE_VPC_CIDR" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "KKE_SUBNET_CIDR" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}
```

### 2. Define Outputs (`outputs.tf`)
Configured the `outputs.tf` file to dynamically extract and display the names of the provisioned resources after deployment.

```hcl
# outputs.tf
output "KKE_vpc_name" {
  value = aws_vpc.xfusion_priv_vpc.tags["Name"]
}

output "KKE_subnet_name" {
  value = aws_subnet.xfusion_priv_subnet.tags["Name"]
}

output "KKE_ec2_private" {
  value = aws_instance.xfusion_priv_ec2.tags["Name"]
}
```

### 3. Build Main Infrastructure (`main.tf`)
Created the `main.tf` file to provision the network layer, security group, and the EC2 instance. A `data` block was utilized to dynamically fetch the latest Amazon Linux 2 AMI, ensuring the code remains resilient and reusable without hardcoding AMI IDs. The subnet was explicitly set to not map public IPs (`map_public_ip_on_launch = false`).

```hcl
# main.tf

# 1. VPC Definition
resource "aws_vpc" "xfusion_priv_vpc" {
  cidr_block = var.KKE_VPC_CIDR
  tags = {
    Name = "xfusion-priv-vpc"
  }
}

# 2. Private Subnet Definition
resource "aws_subnet" "xfusion_priv_subnet" {
  vpc_id                  = aws_vpc.xfusion_priv_vpc.id
  cidr_block              = var.KKE_SUBNET_CIDR
  map_public_ip_on_launch = false
  tags = {
    Name = "xfusion-priv-subnet"
  }
}

# 3. Internal Security Group Definition
resource "aws_security_group" "xfusion_priv_sg" {
  name        = "xfusion-priv-sg"
  description = "Allow internal traffic within the VPC"
  vpc_id      = aws_vpc.xfusion_priv_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = [aws_vpc.xfusion_priv_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Fetch latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 5. EC2 Instance Definition
resource "aws_instance" "xfusion_priv_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.xfusion_priv_subnet.id
  vpc_security_group_ids = [aws_security_group.xfusion_priv_sg.id]

  tags = {
    Name = "xfusion-priv-ec2"
  }
}
```

### 4. Initialization and Application
Executed the standard Terraform workflow to provision the isolated environment.

```bash
terraform init
terraform apply -auto-approve
```

### 5. Final Validation
As required by the task constraints, a final `terraform plan` was executed to ensure the state matched the configuration perfectly without any pending changes.

```bash
terraform plan
# Expected Output: "No changes. Your infrastructure matches the configuration."
```