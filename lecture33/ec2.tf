# -------------------------
# AMI
# -------------------------

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# -------------------------
# EC2
# -------------------------

resource "aws_instance" "test" {

  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public_1a.id

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  key_name = "aws-study-key"

  associate_public_ip_address = true

  tags = {
    Name = "TEST-EC2"
  }
}

# -------------------------
# Elastic IP
# -------------------------

resource "aws_eip" "test" {

  instance = aws_instance.test.id

  domain = "vpc"
}