# ---------------------------------------------
# EC2 ~private-subnet-a~
# ---------------------------------------------
resource "aws_instance" "a" {
  ami           = data.aws_ami.al2023.id
  vpc_security_group_ids =[aws_security_group.for_webserver_ec2.id]
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_a.id
  disable_api_termination = true

  user_data = file("${path.module}/src/user_data.sh")
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }


  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-instance-a"
  })
}

# ---------------------------------------------
# EC2 ~private-subnet-c~
# ---------------------------------------------
# resource "aws_instance" "c" {
#   ami                    = data.aws_ami.al2023.id
#   vpc_security_group_ids =[aws_security_group.for_webserver_ec2.id]
#   instance_type          ="t2.micro"
#   subnet_id              = aws_subnet.private_c.id
# 　disable_api_termination = true
#   metadata_options {
#    http_endpoint               = "enabled"
#    http_tokens                 = "required"
#    http_put_response_hop_limit = 2
#   }
#   user_data= file("${path.module}/src/user_data.sh")
#  tags = merge(local.common_tags, {
#  Name = "${var.project}-${var.environment}-instance-c"
#  })
# }

# ---------------------------------------------
# EC2 ~sg~
# ---------------------------------------------
resource "aws_security_group" "for_webserver_ec2" {
  name   = "${var.project}-${var.environment}-for_webserver_ec2"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-for_webserver_ec2"
    Project = var.project
    Env     = var.environment
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}