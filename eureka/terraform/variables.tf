# eureka/terraform/variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "Eureka AMI ID (optional for destroy)"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Name of the service"
  type        = string
  default     = "eureka"
}

variable "branch" {
  description = "Git branch name"
  type        = string
  default     = "dev"
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
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
  default     = ""
}

variable "security_group_id" {
  description = "Existing security group ID"
  type        = string
  default     = ""
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