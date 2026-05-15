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

variable "service_version" {
  type = string
}

variable "source_ami" {
  description = "Base AMI ID to use for the build"
  type        = string
}


variable "nexus_url" {
  type    = string 
}

variable "eureka_port" {
  type    = string
  default = "8761"
}

source "amazon-ebs" "eureka" {
  ami_name        = "myapp-${var.service_name}-v${var.service_version}"
  instance_type   = "t3.micro"
  region          = "us-east-1"
  source_ami      = var.source_ami
  ssh_username    = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.eureka"]

  provisioner "ansible" {
    playbook_file = "./ansible/playbook-eureka.yml"
    ansible_env_vars = [
      "SERVICE_NAME=${var.service_name}",
      "SERVICE_VERSION=${var.service_version}",
      "NEXUS_URL=${var.nexus_url}",
      "EUREKA_PORT=${var.eureka_port}"
    ]
  }
}