# Nautilus DevOps Task: Day 100 - Create and Configure Alarm Using CloudWatch Using Terraform

## 🎉 Milestone Reached: Day 100! 
*Successfully completing 100 DevOps tasks demonstrates incredible dedication, consistency, and a profound mastery of modern infrastructure engineering.*

## Objective
The Nautilus DevOps team requires robust monitoring for a newly deployed application server. This task involves provisioning an EC2 instance and configuring a CloudWatch Alarm to monitor its CPU utilization. If the CPU utilization equals or exceeds 90% over a consecutive 5-minute period, the alarm must trigger an alert via an existing SNS (Simple Notification Service) topic.

## Environment Details
* **Cloud Provider:** AWS
* **Working Directory:** `/home/bob/terraform`
* **EC2 Instance Name:** `nautilus-ec2` (AMI: `ami-0c02fb55956c7d316`)
* **CloudWatch Alarm Name:** `nautilus-alarm`
* **Metric:** CPU Utilization (Average, >= 90%, 1 period of 300 seconds)
* **SNS Topic:** `nautilus-sns-topic` (Pre-existing resource)

---

## Execution Steps

### 1. Define Outputs (`outputs.tf`)
Created an outputs file to export the dynamically assigned tags and names of the provisioned resources.

```hcl
# outputs.tf
output "KKE_instance_name" {
  value = aws_instance.nautilus_ec2.tags["Name"]
}

output "KKE_alarm_name" {
  value = aws_cloudwatch_metric_alarm.nautilus_alarm.alarm_name
}
```

### 2. Build the Infrastructure (`main.tf`)
Authored the main configuration file. 
*A critical infrastructure-as-code best practice was applied here: instead of attempting to recreate an existing SNS topic (which causes state conflicts), a `data` block was utilized to dynamically fetch the Amazon Resource Name (ARN) of the pre-existing topic.* The EC2 instance was provisioned, and the CloudWatch alarm was bound strictly to this instance using the `dimensions` block.

```hcl
# main.tf

# 1. Fetch the existing SNS topic using a data source
data "aws_sns_topic" "nautilus_sns" {
  name = "nautilus-sns-topic"
}

# 2. Provision the EC2 Instance
resource "aws_instance" "nautilus_ec2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  tags = {
    Name = "nautilus-ec2"
  }
}

# 3. Provision the CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "nautilus_alarm" {
  alarm_name          = "nautilus-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300 # 5 minutes represented in seconds
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Trigger alarm when CPU utilization exceeds 90% for 5 minutes"

  # Bind the alarm to the specific EC2 instance
  dimensions = {
    InstanceId = aws_instance.nautilus_ec2.id
  }

  # Action to trigger on alarm (Send to SNS using the fetched ARN)
  alarm_actions = [data.aws_sns_topic.nautilus_sns.arn]
}
```

### 3. Initialization and Application
Executed the standard Terraform workflow to deploy the monitoring stack.

```bash
terraform init
terraform apply -auto-approve
```

### 4. Final Validation
Executed a final plan command to ensure the state matched the configuration perfectly.

```bash
terraform plan
# Expected Output: "No changes. Your infrastructure matches the configuration."
```