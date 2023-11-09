# ---------------------------------------------
# EC2 ~public-subnet-a~
# ---------------------------------------------
resource "aws_instance" "a" {
  ami           = "ami-078296f82eb463377"
  vpc_security_group_ids =[aws_security_group.for_webserver_ec2.id]
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name    = "${var.project}-${var.environment}-a"
    Project = var.project
    Env     = var.environment
  }
  user_data = <<EOF
  #!/bin/bash

  echo "===sudu su -==="
  sudu su -

  echo "===yum -y update==="
  yum -y update

  echo “===amazon-linux-extras install php7.2 -y===”
  amazon-linux-extras install php7.2 -y

  echo “===yum -y install mysql httpd php-mbstring php-xml gd php-gd===”
  yum -y install mysql httpd php-mbstring php-xml gd php-gd

  echo "===systemctl start httpd.service==="
  systemctl start httpd.service
  echo "===systemctl enable httpd.service==="
  systemctl enable httpd.service

  echo “===wget http://ja.wordpress.org/latest-ja.tar.gz -O /usr/local/src/latest-ja.tar.gz===”
  wget http://ja.wordpress.org/latest-ja.tar.gz -O /usr/local/src/latest-ja.tar.gz

  echo "===cd /usr/local/src/==="
  cd /usr/local/src/

  echo”===tar zxvf latest-ja.tar.gz===”
  tar zxvf latest-ja.tar.gz

  echo”===cp -r wordpress/* /var/www/html/===”
  cp -r wordpress/* /var/www/html/

  echo”===chown apache:apach -R /var/www/html===”
  chown apache:apache -R /var/www/html
  EOF
}

# ---------------------------------------------
# EC2 ~public-subnet-c~
# ---------------------------------------------
# resource "aws_instance" "c" {
#   ami                    ="ami-0c3fd0f5d33134a76"
#   vpc_security_group_ids =[aws_security_group.for_webserver_ec2.id]
#   instance_type          ="t2.micro"
#   subnet_id              = aws_subnet.public_c.id
#   user_data= <<EOF
#!/bin/bash

# echo "===sudu su -==="
# sudu su -

# echo "===yum -y update==="
# yum -y update

# echo “===amazon-linux-extras install php7.2 -y===”
# amazon-linux-extras install php7.2 -y

# echo “===yum -y install mysql httpd php-mbstring php-xml gd php-gd===”
# yum -y install mysql httpd php-mbstring php-xml gd php-gd

# echo "===systemctl start httpd.service==="
# systemctl start httpd.service
# echo "===systemctl enable httpd.service==="
# systemctl enable httpd.service

# echo “===wget http://ja.wordpress.org/latest-ja.tar.gz -O /usr/local/src/latest-ja.tar.gz===”
# wget http://ja.wordpress.org/latest-ja.tar.gz -O /usr/local/src/latest-ja.tar.gz

# echo "===cd /usr/local/src/==="
# cd /usr/local/src/

# echo”===tar zxvf latest-ja.tar.gz===”
# tar zxvf latest-ja.tar.gz

# echo”===cp -r wordpress/* /var/www/html/===”
# cp -r wordpress/* /var/www/html/

# echo”===chown apache:apach -R /var/www/html===”
# chown apache:apache -R /var/www/html
# EOF
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