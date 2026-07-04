#  Secret
resource "aws_secretsmanager_secret" "rds" {
  name = "RDSSecret-260704-02"
}

#  ランダムパスワード
resource "random_password" "rds" {
  length  = 16
  special = false
}

#  Secret登録
resource "aws_secretsmanager_secret_version" "rds" {

  secret_id = aws_secretsmanager_secret.rds.id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.rds.result
  })
}

# -------------------------
# DB Subnet Group
# -------------------------

resource "aws_db_subnet_group" "test" {

  name = "test-db-subnet"

  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
}

# -------------------------
# RDS
# -------------------------

resource "aws_db_instance" "test" {

  identifier = "test-rds"

  engine         = "mysql"
  engine_version = "8.0" #  利用可能な最新8.0系

  instance_class = "db.t4g.micro"

  allocated_storage = 20

  username = "admin"
  password = random_password.rds.result

  skip_final_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.test.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]
}

