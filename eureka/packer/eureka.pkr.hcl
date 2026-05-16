packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "service_name" {
  type = string
}

variable "git_branch" {
  type        = string
  default     = "master"
  description = "Git branch being built"
}

variable "service_version" {
  type = string
}

variable "source_ami" {
  description = "Base AMI ID to use for the build"
  type        = string
}

variable "nexus_url" {
  type = string
}

variable "eureka_port" {
  type    = string
  default = "8761"
}

source "amazon-ebs" "eureka" {
  # Include branch name in AMI name for better identification
  ami_name        = "myapp-${var.service_name}-${var.service_version}-${var.git_branch}-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
  instance_type   = "t3.micro"
  region          = "us-east-1"
  source_ami      = var.source_ami
  ssh_username    = "ubuntu"
  
  tags = {
    Name        = "${var.service_name}-ami-${var.service_version}-${var.git_branch}"
    Service     = var.service_name
    Version     = var.service_version
    Branch      = var.git_branch
    BuiltBy     = "Jenkins"
    Environment = var.git_branch == "master" || var.git_branch == "main" ? "production" : (var.git_branch == "qa" ? "staging" : "development")
    Timestamp   = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
  }
}

build {
  sources = ["source.amazon-ebs.eureka"]

  provisioner "ansible" {
    playbook_file = "./ansible/playbook-eureka.yml"
    ansible_env_vars = [
      "SERVICE_NAME=${var.service_name}",
      "SERVICE_VERSION=${var.service_version}",
      "NEXUS_URL=${var.nexus_url}",
      "EUREKA_PORT=${var.eureka_port}",
      "GIT_BRANCH=${var.git_branch}"
    ]
  }
}