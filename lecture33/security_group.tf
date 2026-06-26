# -------------------------
# ALB
# -------------------------

resource "aws_security_group" "alb" {
  name   = "TEST-SecurityGroupALB"
  vpc_id = aws_vpc.test.id
}

# 80番許可
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

# -------------------------
# EC2
# -------------------------

resource "aws_security_group" "ec2" {
  name_prefix = "TEST-SecurityGroupEC2"
  description = "TEST-SecurityGroupEC2"
  vpc_id      = aws_vpc.test.id

  # SSH
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["175.177.6.36/32"]
  }

  # HTTP from ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TEST-SG-EC2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -------------------------
# RDS
# -------------------------

resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.test.id
}