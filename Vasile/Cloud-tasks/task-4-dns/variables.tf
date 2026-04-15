variable "aws_region" {
  type = string
  default = "eu-west-3"
}

variable "instance_type" {
    type = string 
    default = "t2.nano"
}

variable "public_key_value" {
  description = "Key string"
  type        = string
  sensitive   = true
}

variable "office_ip" {
  type = string
  default = "217.12.117.42"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}