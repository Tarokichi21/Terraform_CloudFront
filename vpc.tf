# ---------------------------------------------
# VPC
# ---------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-vpc"
  })
}

# ---------------------------------------------
# Internet Gateway
# ---------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-igw"
  })
}

# ---------------------------------------------
# Public Subnets
# ---------------------------------------------
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-a"
    Type = "public"
  })
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-c"
    Type = "public"
  })
}

# ---------------------------------------------
# Private Subnets
# ---------------------------------------------
locals {
  private_subnets = {
    a = aws_subnet.private_a.id
    c = aws_subnet.private_c.id
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-1a"

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-a"
    Type = "private"
  })
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "ap-northeast-1c"

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-c"
    Type = "private"
  })
}

# ---------------------------------------------
# NAT Gateway(Single)
# ---------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-nat-eip"
  })
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat.id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-nat"
  })
}

# ---------------------------------------------
# Public Route Table
# ---------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public"
  })
}

# ---------------------------------------------
# Public Association（for_each）
# ---------------------------------------------
resource "aws_route_table_association" "public" {
  for_each = {
    a = aws_subnet.public_a.id
    c = aws_subnet.public_c.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------
# Private Route Tables（for_each）
# ---------------------------------------------
resource "aws_route_table" "private" {
  for_each = {
    a = aws_subnet.private_a.id
    c = aws_subnet.private_c.id
  }

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-${each.key}"
  })
}

# ---------------------------------------------
# Private Association（for_each）
# ---------------------------------------------
resource "aws_route_table_association" "private" {
  for_each = {
    a = aws_subnet.private_a.id
    c = aws_subnet.private_c.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.private[each.key].id
}