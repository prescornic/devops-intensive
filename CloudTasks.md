# Cloud Tasks (AWS)

These tasks are meant to practice core AWS infrastructure operations: network segmentation, secure access, managed databases, compute + web serving, DNS, and static website hosting.

## General requirements (apply to all tasks)

- Use a dedicated AWS account (or a dedicated sandbox AWS environment). and Paris region
- Use least-privilege IAM permissions.
- Do **not** commit credentials/keys to git.
- Tag all created resources (at minimum: `Project`, `Owner`, `Environment`).
- Keep notes with the exact AWS region used.
- Provide evidence for each task: commands used and/or screenshots.

## 1) Bastion host (jump box) + SSH access

**Description**
Create a bastion host in a public subnet to securely reach private resources via SSH.

**Task requirements**
- Create a VPC with at least:
	- 1 public subnet (for the bastion)
	- 1 private subnet (for future private resources)
	- Internet Gateway attached + public subnet route to the IGW
- Launch an EC2 instance as the bastion host in the public subnet.
- Configure Security Group rules:
	- Inbound: `SSH (22)` only from **your** public IP (no `0.0.0.0/0`)
	- Outbound: allow required egress (default is ok)
- Connect via SSH from your local machine to the bastion host.

**Acceptance criteria**
- You can run `ssh` to the bastion and get a shell.
- You can show the Security Group inbound rule is restricted to your IP.

## 2) RDS database (public), then private + access patterns

**Description**
Create an RDS database with public access, connect to it, create tables and insert data, then recreate it privately and access it through the bastion and via an SSH tunnel.

**Task requirements**
- Create an RDS instance with **public access enabled**.
- Ensure the DB engine is one of: PostgreSQL or MySQL.
- Configure Security Group rules:
	- Inbound: DB port only from **your** public IP (no `0.0.0.0/0`)
- Connect from your local machine using a DB client.
- Create at least:
	- 1 database/schema (if applicable)
	- 2 tables
	- Insert at least 5 rows
	- Run a `SELECT` query proving the data exists

### 2.1) Recreate RDS with private access + bastion access + SSH tunnel

**Task requirements**
- Recreate (or create a second) RDS instance with **public access disabled** in private subnets.
- Configure Security Group rules:
	- Inbound: DB port allowed only from the bastion host Security Group (SG-to-SG rule)
- From the bastion host, connect to the private RDS instance using CLI client (`psql` / `mysql`) or an installed DB client.
- From your local machine, connect to the private RDS instance using an **SSH tunnel** through the bastion.

**Acceptance criteria**
- The private RDS endpoint is not publicly reachable.
- You can successfully query the private DB:
	- from the bastion directly
	- from your laptop via SSH tunnel through the bastion

## 3) EC2 web server (nginx) + custom page

**Description**
Create an EC2 instance running nginx and serve a custom `index.html` accessible from your local machine.

**Task requirements**
- Launch an EC2 instance in a subnet that is reachable from the internet (public subnet).
- Install nginx.
- Deploy a custom `index.html` page (any content is fine, but must be clearly identifiable as yours).
- Configure Security Group rules:
	- Inbound: `HTTP (80)` from your public IP (or `0.0.0.0/0` if explicitly allowed by your trainer)
	- Inbound: `SSH (22)` only from your public IP

**Acceptance criteria**
- Visiting `http://<public-ip-or-dns>/` from your laptop shows your custom HTML page.

## 4) Route 53 hosted zone + DNS record for your app instance

**Description**
Create DNS records so the EC2 web server is reachable via a domain name.

**Task requirements**
- Create a Route 53 hosted zone for a domain you control (or use a provided training domain).
- Add a DNS record pointing to the EC2 instance:
	- If using an Elastic IP: `A` record to the EIP
	- If using an AWS hostname: `CNAME` record to the public DNS name
- Set a sensible TTL (e.g., 60–300 seconds for training).

**Acceptance criteria**
- Accessing the domain in a browser resolves and serves your nginx page.

## 5) S3 static website hosting

**Description**
Host a simple static website from S3 and access it from a browser.

**Task requirements**
- Create an S3 bucket.
- Upload an `index.html`.
- Enable S3 static website hosting.
- Make the content publicly readable *only as needed for the website*:
	- Prefer bucket policy scoped to `s3:GetObject` for `arn:aws:s3:::<bucket>/*`
	- Avoid broad permissions beyond what the task requires

**Acceptance criteria**
- You can open the S3 website endpoint URL and see the `index.html` content.