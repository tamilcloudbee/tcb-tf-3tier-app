output "public_instance_id" {
  description = "The ID of the public EC2 instance"
  value       = aws_instance.public_instance.id
}

output "public_instance_private_ip" {
  description = "The private IP of the public EC2 instance"
  value       = aws_instance.public_instance.private_ip
}

output "ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}


