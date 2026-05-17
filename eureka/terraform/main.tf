# eureka/terraform/main.tf

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to get the latest Eureka AMI (fallback if not provided)
data "aws_ami" "eureka" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["myapp-eureka-*${var.branch}*"]
  }
}

# Use existing security group (no need to create)
data "aws_security_group" "existing" {
  id = var.security_group_id
}

# EC2 Instance (using existing security group)
resource "aws_instance" "eureka" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.eureka.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name        = "${var.service_name}-${var.environment}"
    Environment = var.environment
    Service     = var.service_name
    Branch      = var.branch
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

