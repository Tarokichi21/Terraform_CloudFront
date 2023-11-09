# provider "aws" {
#     profile = "default"
#     region  = "ap-northeast-1"
# }
# ---------------------------------------------
# VPC
# ---------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block                       = "10.0.0.0/16"
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name    = "${var.project}-${var.environment}-vpc"
    Project = var.project
    Env     = var.environment
  }
}
# ---------------------------------------------
# public subnet
# ---------------------------------------------
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name    = "${var.project}-${var.environment}-public_a"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name    = "${var.project}-${var.environment}-public_c"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

# ---------------------------------------------
# internet gateway
# ---------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.environment}-igw"
    Project = var.project
    Env     = var.environment
  }
}
# ---------------------------------------------
# routetable public
# ---------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-${var.environment}-public"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}
# ---------------------------------------------
# public route（IGW）
# ---------------------------------------------
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
# ---------------------------------------------
# association
# ---------------------------------------------
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}
# ---------------------------------------------
# private subnet
# ---------------------------------------------
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name    = "${var.project}-${var.environment}-private-a"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name    = "${var.project}-${var.environment}-private-c"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}
# ---------------------------------------------
# Elasti IP
# ---------------------------------------------
resource "aws_eip" "nat_a" {
  vpc = true

  tags = {
    Name = "natgw-eip"
  }
}
# ---------------------------------------------
# NAT Gateway
# ---------------------------------------------
resource "aws_nat_gateway" "nat_a" {
  subnet_id     = aws_subnet.public_a.id 
  allocation_id = aws_eip.nat_a.id

  tags = {
    Name = "natgw-a"
  }
}
# ---------------------------------------------
# Route Table (Private)
# ---------------------------------------------
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-private_a"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-private_c"
    Project = var.project
    Env     = var.environment
    Type    = "private"
  }
}
# ---------------------------------------------
# route (private)
# ---------------------------------------------
resource "aws_route" "private_a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_a.id
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route" "private_c" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_c.id
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

# ---------------------------------------------
# association (private)
# ---------------------------------------------
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}
