# --- 1. MÓNG (VPC & INTERNET GATEWAY) ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "d-vpc-aivn-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "d-vpc-aivn-igw" }
}

# --- 2. PHÂN LÔ (4 SUBNETS RỜI NHAU) ---
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  tags              = { Name = "d-vpc-aivn-public1" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}a"
  tags              = { Name = "d-vpc-aivn-private1" }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}b"
  tags              = { Name = "d-vpc-aivn-public2" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.region}b"
  tags              = { Name = "d-vpc-aivn-private2" }
}

# --- 3. CỔNG NAT (DÀNH CHO VÙNG PRIVATE) ---
resource "aws_eip" "nat" { domain = "vpc" }
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  tags          = { Name = "d-vpc-aivn-nat" }
}

# --- 4. (3 ROUTE TABLES RỜI) ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "d-vpc-aivn-rtb-public" }
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "d-vpc-aivn-rtb-private1" }
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "d-vpc-aivn-rtb-private2" }
}


resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "a3" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}
resource "aws_route_table_association" "a4" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}


resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.public.id,
    aws_route_table.private_1.id,
    aws_route_table.private_2.id
  ]
  tags = { Name = "d-vpc-aivn-vpce-s3" }
}
