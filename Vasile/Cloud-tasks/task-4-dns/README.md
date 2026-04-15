# AWS Infrastructure Task 4: Route 53 & DNS Management

## Overview
This project automates the deployment of a web server infrastructure on AWS using Terraform. It expands on previous tasks by implementing DNS management via Route 53 to reach the EC2 instance via a custom domain name.

## Infrastructure Components
- **VPC & Networking:** Custom VPC with an Internet Gateway and Public Subnet.
- **Security Group:** Rules allowing HTTP (Port 80) from anywhere and SSH (Port 22) restricted to a specific administrative IP.
- **Compute:** A `t2.nano` instance running Nginx, provisioned via Bash script (User Data).
- **DNS Logic:**
  - **Route 53 Hosted Zone:** Created for the domain `devops-vasile.duckdns.org`.
  - **CNAME Record:** An `app` subdomain record pointing to the AWS Public DNS hostname of the EC2 instance.

## DNS Verification & Mapping
Since the domain utilized is a third-party free domain (`duckdns.org`), the following step was taken to verify the Route 53 configuration without global DNS propagation delays:

### Local DNS Mapping (Verification)
To access the server via the domain name in a browser for acceptance testing, a local entry was added to the `/etc/hosts` file.

## Evidence

![alt text](<../task-4-dns/evidence/1.png>)

![alt text](<../task-4-dns/evidence/2.png>)
