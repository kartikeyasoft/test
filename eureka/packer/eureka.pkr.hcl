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

variable "service_name"    { type = string }
variable "git_branch"      { type = string, default = "dev" }
variable "service_version" { type = string }
variable "source_ami"      { type = string }
variable "nexus_url"       { type = string }
variable "eureka_port"     { type = string, default = "8761" }
variable "git_commit"      { type = string, default = "unknown" }
variable "build_number"    { type = string, default = "local" }

locals {
  # Clean branch name by replacing special characters
  clean_branch = replace(var.git_branch, "/", "-")
  
  # Environment mapping - master/main -> prod, all others use branch name
  environment = var.git_branch == "master" || var.git_branch == "main" ? "prod" : var.git_branch
  
  # Generate timestamp for unique naming
  timestamp = formatdate("YYYYMMDD-HHmmss", timestamp())
  date      = formatdate("YYYYMMDD", timestamp())
  time      = formatdate("HHmmss", timestamp())
}

source "amazon-ebs" "eureka" {
  ami_name      = "myapp-${var.service_name}-${var.service_version}-${local.clean_branch}-${local.timestamp}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami    = var.source_ami
  ssh_username  = "ubuntu"
  
  # Temporary instance naming for easy identification
  temp_name = "packer-${var.service_name}-${var.service_version}-${local.clean_branch}-${local.timestamp}"
  
  # Optional: Add temporary instance tags (requires additional config)
  temporary_instance_tags = {
    Name        = "packer-${var.service_name}-${var.service_version}-${local.clean_branch}"
    Service     = var.service_name
    Version     = var.service_version
    Branch      = var.git_branch
    Environment = local.environment
    PackerBuild = "true"
    TempInstance = "true"
    BuildNumber = var.build_number
    BuiltBy     = "packer"
    AutoCleanup = "true"
  }
  
  tags = {
    Name            = "${var.service_name}-ami-${var.service_version}-${local.clean_branch}"
    Service         = var.service_name
    Version         = var.service_version
    Branch          = var.git_branch
    Environment     = local.environment
    BuiltBy         = "Jenkins"
    BuildNumber     = var.build_number
    GitCommit       = var.git_commit
    Timestamp       = formatdate("YYYY-MM-DD HH:mm:ss", timestamp())
    EurekaPort      = var.eureka_port
    SourceAMI       = var.source_ami
    BuildDate       = local.date
    BuildTime       = local.time
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
      "GIT_BRANCH=${var.git_branch}",
      "ENVIRONMENT=${local.environment}",
      "GIT_COMMIT=${var.git_commit}",
      "BUILD_NUMBER=${var.build_number}"
    ]
  }
}