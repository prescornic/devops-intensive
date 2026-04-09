resource "aws_security_group" "db_sg" {
  name        = "vvd-db-sg-phase1"
  description = "Allow PG traffic from Office IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.office_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "vvd-db-sg" }
}