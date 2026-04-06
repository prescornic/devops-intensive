# Task 1: AWS Bastion Host (Jump Box) with Infrastructure as Code

This project demonstrates the deployment of a secure Bastion Host (Jump Box) within a custom AWS VPC using **Terraform**. The architecture ensures that private resources remain inaccessible from the internet while providing a single, hardened entry point for administrators.

## Architecture Overview

The infrastructure consists of the following components:
- **VPC:** A custom 10.0.0.0/16 network.
- **Subnets:** - `10.0.1.0/24` (Public) - Hosts the Bastion instance.
  - `10.0.2.0/24` (Private) - Isolated for backend resources.
- **Connectivity:** Internet Gateway (IGW) attached to the VPC with a Route Table allowing outbound traffic for the public subnet.
- **Compute:** An EC2 `t2.nano` instance running **Ubuntu 24.04 LTS**.
- **Security:** A Security Group (SG) configured with **Strict Ingress Control**, allowing SSH (Port 22) access *only* from the administrator's current public IP.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) (v1.0+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials.
- An existing SSH Key Pair (ED25519 or RSA).

## Deployment Steps

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```
2. **Set Public Key Variable:**
To avoid hardcoding sensitive information, the public key is passed via an environment variable:
   ```bash
   export TF_VAR_public_key_value="... your_key"
   ```
3. **Apply the terraform**

**Once applied, note the bastion_public_ip**

4. **Verify Connectivity:**
   ```bash
   ssh -i ~/.ssh/your_private_key ubuntu@<bastion_public_ip>
   ```
**Evidence:**

![alt text](<../task-1-aws-bastion/evidence/cloud_task_1_e1.png>)

![alt text](<../task-1-aws-bastion/evidence/cloud_task_1_e2.png>)

![alt text](<../task-1-aws-bastion/evidence/cloud_task_1_e3.png>)

![alt text](<../task-1-aws-bastion/evidence/cloud_task_1_e4.png>)

![alt text](<../task-1-aws-bastion/evidence/cloud_task_1_e5.png>)