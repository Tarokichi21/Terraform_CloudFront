### EC2
resource "aws_instance" "a" {
  ami                    = "ami-08928044842b396f0"
  vpc_security_group_ids = [aws_security_group.for_webserver_ec2.id]
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_a.id

  tags = {
    Name = "terraform_EC2"
  }
  user_data = <<EOF
  #!/bin/bash
  yum update -y
  yum upgrade -y
  yum install httpd -y
  systemctl enable httpd
  systemctl start httpd
  touch /var/www/html/index.html
  echo "CloudFront -> ALB -> EC2" > /var/www/html/index.html
  EOF
}

### security group(EC2)
resource "aws_security_group" "for_webserver_ec2" {
  name   = "terraform_sg_ec2"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform_EC2_sg"
  }
}
resource "aws_security_group_rule" "ec2_in_http" {
  security_group_id        = aws_security_group.for_webserver_ec2.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ec2_in_https" {
  security_group_id        = aws_security_group.for_webserver_ec2.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ec2_out_mysql" {
  security_group_id = aws_security_group.for_webserver_ec2.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}