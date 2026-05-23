# ---------------------------------------------
# RDS MySQL
# ---------------------------------------------
resource "aws_db_instance" "mysql" {
  identifier = "${var.project}-${var.environment}-mysql"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "db_name"
  username = "admin"
  password = "ChangeMe123!"

  parameter_group_name = "default.mysql8.0"

  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.name
  vpc_security_group_ids = [aws_security_group.for_rds.id]

  multi_az = false

  publicly_accessible = false

  skip_final_snapshot = true

  deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-mysql"
  })
}

# ---------------------------------------------
# RDS Subnet Group
# ---------------------------------------------
resource "aws_db_subnet_group" "dbsubnet" {
  name = "${var.project}-${var.environment}-dbsubnet"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-dbsubnet"
  })
}

# ---------------------------------------------
# RDS Security Group
# ---------------------------------------------
resource "aws_security_group" "for_rds" {
  name   = "${var.project}-${var.environment}-rds-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.for_webserver_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-rds-sg"
  })
}