# ---------------------------------------------
# RDS
# ---------------------------------------------
resource "aws_db_instance" "mysql" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  identifier             = "${var.project}-${var.environment}-mysql"
  instance_class         = "db.t2.micro"
  name                   = "db_name"  #secrets managerはmust
  username               = "username" #secrets managerはmust
  password               = "password" #secrets managerはmust
  parameter_group_name   = "default.mysql5.7"
  multi_az               = false
  availability_zone      = "ap-northeast-1a"
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.for_rds.id]

  tags = {
    Name    = "${var.project}-${var.environment}-mysql"
    Project = var.project
    Env     = var.environment
  }
}
# ---------------------------------------------
# subnet-group
# ---------------------------------------------
resource "aws_db_subnet_group" "dbsubnet" {
  name       = "${var.project}-${var.environment}-dbsubnet"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_c.id]

  tags = {
    Name    = "${var.project}-${var.environment}-dbsubnet"
    Project = var.project
    Env     = var.environment
  }
}
# ---------------------------------------------
# RDS ~sg~
# ---------------------------------------------

resource "aws_security_group" "for_rds" {
  name   = "${var.project}-${var.environment}-for_rds"
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
    Name    = "${var.project}-${var.environment}-for_rds"
    Project = var.project
    Env     = var.environment
  }
}