# -------------------------
# ALB
# -------------------------

resource "aws_lb" "test" {

  name = "TEST-ELB"

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]
}

# -------------------------
# Target Group
# -------------------------

resource "aws_lb_target_group" "test" {

  name_prefix = "testtg"

  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.test.id

  health_check {
    path     = "/"
    port     = "traffic-port"
    protocol = "HTTP"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#  EC2登録
resource "aws_lb_target_group_attachment" "test" {

  target_group_arn = aws_lb_target_group.test.arn

  target_id = aws_instance.test.id

  port = 8080
}

#  Listener
resource "aws_lb_listener" "test" {

  load_balancer_arn = aws_lb.test.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}