output "bastion_public_ip" {
  description = "The public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}