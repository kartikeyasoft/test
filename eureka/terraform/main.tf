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

# Create security group
resource "aws_security_group" "eureka" {
  name        = "eureka-sg-${var.environment}"
  description = "Security group for Eureka service registry"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.eureka_port
    to_port     = var.eureka_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Eureka dashboard"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "eureka-sg-${var.environment}"
    Environment = var.environment
    Service     = var.service_name
    Branch      = var.branch
    ManagedBy   = "terraform"
  }
}

# EC2 Instance
resource "aws_instance" "eureka" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.eureka.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.eureka.id]
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

# Optional: Elastic IP
resource "aws_eip" "eureka" {
  count = var.assign_eip ? 1 : 0
  instance = aws_instance.eureka.id
  domain   = "vpc"

  tags = {
    Name        = "${var.service_name}-eip-${var.environment}"
    Environment = var.environment
    Service     = var.service_name
  }
}

# Outputs
output "eureka_private_ip" {
  description = "Private IP of Eureka instance"
  value       = aws_instance.eureka.private_ip
}

output "eureka_public_ip" {
  description = "Public IP of Eureka instance"
  value       = aws_instance.eureka.public_ip
}

output "eureka_ami" {
  description = "AMI ID used for the instance"
  value       = aws_instance.eureka.ami
}