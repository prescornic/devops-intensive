resource "aws_db_instance" "postgres" {
  allocated_storage      = var.db_allocated_storage
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name = "default.postgres16"
  skip_final_snapshot    = true
  
  db_subnet_group_name   = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [aws_security_group.db_sec_g.id]
  
  publicly_accessible    = false

  tags = { Name = "vvd-postgres-private" }
}
