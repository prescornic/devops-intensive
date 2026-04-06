variable "aws_region" {
  default = "eu-west-3"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_key_value" {
  description = "Key string"
  type        = string
  sensitive   = true
}