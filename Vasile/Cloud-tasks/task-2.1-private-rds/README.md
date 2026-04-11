# Task 2.1: Private RDS Access via Bastion & SSH Tunnel

This project implements a secure, production-standard database architecture. The RDS instance is located in a private subnet with no direct internet access, and connectivity is managed via a Bastion host (Jump Box) using SSH tunneling.

## Architecture Highlights
- **Network Security:** RDS is deployed in private subnets; public access is disabled.
- **Bastion Host:** A `t2.nano` Ubuntu instance acting as the secure gateway.
- **SG-to-SG Rules:** The RDS Security Group strictly allows inbound traffic on port 5432 **only** from the Bastion host's Security Group ID.
- **SSH Tunneling:** Secure local port forwarding is used to bridge the local machine to the private database.

## Evidence

![alt text](<../task-2.1-private-rds/evidence/1.png>)

![alt text](<../task-2.1-private-rds/evidence/2.png>)

![alt text](<../task-2.1-private-rds/evidence/3.png>)

![alt text](<../task-2.1-private-rds/evidence/4.png>)

![alt text](<../task-2.1-private-rds/evidence/5.png>)
