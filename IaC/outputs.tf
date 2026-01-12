
output "instance_ip" {

  description = "External IP of instance"
  value       = aws_instance.example.public_ip
}

output "instance_private_ip" {
  description = "Private IP of instance"
  value       = aws_instance.example.private_ip
}

output "bucket_region" {
  description = "S3 Bucket zone"
  value       = aws_s3_bucket.website_bucket.bucket_regional_domain_name


}