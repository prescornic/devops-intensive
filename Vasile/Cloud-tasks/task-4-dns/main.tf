provider "aws" {
  region = var.aws_region
}

output "public_ip" {
  value = aws_instance.nginx_server.public_ip
}