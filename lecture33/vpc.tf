# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "test" {

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TEST-VPC"
  }
}

# -------------------------
# Public Subnet
# -------------------------

resource "aws_subnet" "public_1a" {

  vpc_id = aws_vpc.test.id

  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "TEST-PublicSubnet-1a"
  }
}

resource "aws_subnet" "public_1c" {

  vpc_id = aws_vpc.test.id

  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"

  map_public_ip_on_launch = true

  tags = {
    Name = "TEST-PublicSubnet-1c"
  }
}

# -------------------------
# Private Subnet
# -------------------------

resource "aws_subnet" "private_1a" {

  vpc_id = aws_vpc.test.id

  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "TEST-PrivateSubnet-1a"
  }
}

resource "aws_subnet" "private_1c" {

  vpc_id = aws_vpc.test.id

  cidr_block        = "10.0.20.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "TEST-PrivateSubnet-1c"
  }
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "test" {

  vpc_id = aws_vpc.test.id

  tags = {
    Name = "TEST-IGW"
  }
}

# -------------------------
# Route Table
# -------------------------

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.test.id

  tags = {
    Name = "TEST-RouteTable"
  }
}

resource "aws_route" "public_internet_access" {

  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.test.id
}

# -------------------------
# Route Table Association
# -------------------------

resource "aws_route_table_association" "public_1a" {

  subnet_id = aws_subnet.public_1a.id

  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {

  subnet_id = aws_subnet.public_1c.id

  route_table_id = aws_route_table.public.id
}