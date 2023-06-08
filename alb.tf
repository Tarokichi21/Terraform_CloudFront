
### ALB
resource "aws_lb" "for_webserver" {
  name               = "webserver-alb"
  internal           = false #falseを指定するとインターネット向け,trueを指定すると内部向け
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id,
  ]
}
### security group(ALB)
resource "aws_security_group" "alb_sg" {
  name   = "terraform_ALB_sg"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "terraform_ALB_sg"
  }
}
resource "aws_security_group_rule" "alb_in_http" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_in_https" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_out_ec2" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

### ALB listner
resource "aws_lb_listener" "forward_HTTP" {
  load_balancer_arn = aws_lb.for_webserver.arn
  port              = "80"
  protocol          = "HTTP"
  ### ALBからアクセスできないようにする
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }

  }

}

### Listener-Rule（HTTP）
resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.forward_HTTP.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.for_webserver.arn

  }

  condition {
    http_header {
      http_header_name = "Custom-Header"
      values           = ["test-Custom-Header"]
    }
  }
}

### target group(ALB)
resource "aws_lb_target_group" "for_webserver" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name = "alb-tg"
  }
}

### target group attachment
resource "aws_lb_target_group_attachment" "for_webserver_a" {
  target_group_arn = aws_lb_target_group.for_webserver.arn
  target_id        = aws_instance.a.id
  port             = 80
}