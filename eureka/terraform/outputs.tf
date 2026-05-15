output "eureka_instance_id" {
  description = "ID of the Eureka EC2 instance"
  value       = aws_instance.eureka.id
}

output "eureka_public_ip" {
  description = "Public IP of Eureka instance"
  value       = aws_instance.eureka.public_ip
}

output "eureka_private_ip" {
  description = "Private IP of Eureka instance"
  value       = aws_instance.eureka.private_ip
}

output "eureka_dashboard_url" {
  description = "URL to access Eureka dashboard"
  value       = "http://${aws_instance.eureka.public_ip}:8761"
}

output "used_ami_id" {
  description = "AMI ID used for deployment"
  value       = var.ami_id != "" ? var.ami_id : data.aws_ami.eureka.id
}

output "security_group_id" {
  description = "Security group ID used for Eureka"
  value       = aws_security_group.eureka.id
}
