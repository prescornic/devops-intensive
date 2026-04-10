# Task 2: Publicly Accessible RDS with Terraform

This project demonstrates the deployment of a publicly accessible AWS RDS (PostgreSQL) instance within a custom VPC, managed entirely via Terraform. It includes the configuration of networking components, security groups for remote access, and database initialization.

## Infrastructure Components
- **VPC & Networking:** Custom VPC with Public Subnets, Internet Gateway, and Route Tables.
- **RDS Instance:** PostgreSQL 16 on `db.t3.micro`.
- **Security:** Security Group configured to allow inbound PostgreSQL traffic (Port 5432) from authorized IP ranges.
- **Encryption:** SSL/TLS enforced for all database connections using the AWS RDS Global Bundle.

**Evidence:**

![alt text](<../task-2-public-rds/evidence/1.png>)

![alt text](<../task-2-public-rds/evidence/2.png>)

![alt text](<../task-2-public-rds/evidence/3.png>)
