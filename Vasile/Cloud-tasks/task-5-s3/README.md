# AWS Infrastructure Task 5: S3 Static Website Hosting

## Overview
This project demonstrates the deployment of a serverless static website using Amazon S3. 

## Technical Stack
- **Cloud Provider:** AWS
- **IaC Tool:** Terraform
- **Service:** Amazon S3 (Simple Storage Service)
- **Content:** HTML5

## Infrastructure Components
- **S3 Bucket:** A globally unique bucket with `force_destroy` enabled for clean resource removal.
- **Static Website Configuration:** Configured to serve `index.html` as the default root document.
- **Public Access Management:** - Disabled `Block Public Access` settings to allow bucket-level permissions.
  - Implemented a **Bucket Policy** explicitly scoped to `s3:GetObject` for public read access.
- **Object Management:** Automated upload of `index.html` with the correct `text/html` Content-Type metadata to ensure browser rendering.

## Evidence

![alt text](<../task-5-s3/evidence/1.png>)

![alt text](<../task-5-s3/evidence/2.png>)
