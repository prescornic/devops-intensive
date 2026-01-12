resource "aws_s3_bucket" "website_bucket" {
  bucket = "sm-devops-intensive-bucket-260112" # Change to a unique name

  tags = {
    Name        = var.instance_name
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "storage_bucket" {
  bucket = "sm-devops-storage-bucket-260112" # Change to a unique name

  tags = {
    Name        = var.instance_name
    Environment = "Dev"
  }
}