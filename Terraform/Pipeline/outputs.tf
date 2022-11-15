output "jenkinsec2publicip" {
  description = "The public ip of the jenkins ec2"
  value       = aws_instance.jenkins.public_ip
}

output "terraformec2publicip" {
  description = "The public ip of the terraform ec2"
  value       = aws_instance.terraform.public_ip
}

output "dockerec2publicip" {
  description = "The public ip of the docker ec2"
  value       = aws_instance.docker.public_ip
}