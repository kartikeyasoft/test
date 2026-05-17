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