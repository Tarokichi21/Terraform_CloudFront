### RDS
resource "aws_db_instance" "mysql" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  identifier             = "db-1"
  instance_class         = "db.t2.micro"
  name                   = "db_name"
  username               = "username"
  password               = "password"
  parameter_group_name   = "default.mysql8.0"
  multi_az               = false
  availability_zone      = "ap-northeast-1a"
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.for_rds.id]

  tags = {
    Name = "terraform_rds"
  }
}
### DB subnet group
resource "aws_db_subnet_group" "dbsubnet" {
  name       = "terraform_db_subnet_group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_c.id]

  tags = {
    Name = "terraform_db_subnet_group"
  }
}

### Security Group(RDS)
resource "aws_security_group" "for_rds" {
  name   = "terraform_DB_sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform_DB_sg"
  }
}