### VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = "10.0.0.0/16"
  instance_tenancy                 = "default" #ハードウェア占有インスタンスを立てるかどうか
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "terraform_vpc"
  }
}

### public subnet
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true #サブネットで起動したインスタンスにパブリックIPを許可する
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "terraform_public_1a"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name = "terraform_public_1c"
  }
}

### Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "terraform_igw"
  }
}
### Route Table (Public)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "terraform_route_table_public"
  }
}

### Route (Public)
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

### Association (Public)
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

### private subnet
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = false #サブネットで起動したインスタンスにパブリックIPを許可する
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "terraform_private_1a"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name = "terraform_private_1c"
  }
}

### Elastic IP
resource "aws_eip" "nat_a" {
  vpc = true

  tags = {
    Name = "terraform_natgw_eip"
  }
}

### NAT Gateway
resource "aws_nat_gateway" "nat_a" {
  subnet_id     = aws_subnet.public_a.id # NAT Gatewayを配置するSubnetを指定
  allocation_id = aws_eip.nat_a.id       # 紐付けるElasti IP

  tags = {
    Name = "terraform_natgw_a"
  }
}

### Route Table (Private)
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform_route_table_private_a"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform_route_table_private_c"
  }
}

### Route (Private)
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

### Association (Private)
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}
