variable "aws_region" {
  default = "eu-west-3"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.11.0/24"]
}

variable "db_name" {
  type        = string
  sensitive   = false
  default = "vvd_pg_db"
}

variable "db_username" {
  type = string
  sensitive = false
  default = "admin_vvd"
}

variable "db_password" {
  type      = string
  sensitive = true
  default = ""
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "office_ip" {
  type = string
  default = "217.12.117.42"
}