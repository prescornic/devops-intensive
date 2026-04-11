provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "vvd-bastion-vpc" }
}

resource "aws_internet_gateway" "gandalf" {
  vpc_id = aws_vpc.main.id
}
