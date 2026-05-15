variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "ami_id" {
  description = "Eureka AMI ID (optional for destroy)"
  type        = string
  default     = ""  # Make it optional with default
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "eureka_port" {
  description = "Port for Eureka server"
  type        = number
  default     = 8761
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
  default     = "subnet-0aa31e769c8f4d73e"
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
  default     = "vpc-0cb7deb47a6bfa727"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "ksansible"
}

variable "assign_eip" {
  description = "Assign Elastic IP to instance"
  type        = bool
  default     = false
}
