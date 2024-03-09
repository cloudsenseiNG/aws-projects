resource "aws_vpc" "wordpress_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.dns_host
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.public_cidr_block_a
  availability_zone       = var.az_a
  map_public_ip_on_launch = var.public_ip_map
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.public_cidr_block_b
  availability_zone       = var.az_b
  map_public_ip_on_launch = var.public_ip_map
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.private_cidr_block_a
  availability_zone       = var.az_a
  map_public_ip_on_launch = var.private_ip_map
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.private_cidr_block_b
  availability_zone       = var.az_b
  map_public_ip_on_launch = var.private_ip_map
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.private_cidr_block_c
  availability_zone       = var.az_a
  map_public_ip_on_launch = var.private_ip_map
}

resource "aws_subnet" "private_subnet_d" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  cidr_block              = var.private_cidr_block_d
  availability_zone       = var.az_b
  map_public_ip_on_launch = var.private_ip_map
}

resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = aws_vpc.wordpress_vpc.id
}

resource "aws_route_table" "public_subnet_route" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = var.external_cidr_block
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_a_asso" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_subnet_route.id
}

resource "aws_route_table_association" "public_subnet_b_asso" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_subnet_route.id
}

resource "aws_nat_gateway" "nat_az_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.public_subnet_a.id
  depends_on    = [aws_internet_gateway.wordpress_igw]
}

resource "aws_nat_gateway" "nat_az_b" {
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id     = aws_subnet.public_subnet_b.id
  depends_on    = [aws_internet_gateway.wordpress_igw]
}

resource "aws_route_table" "az_a_route_table" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = var.external_cidr_block
    gateway_id = aws_nat_gateway.nat_az_a.id
  }
}

resource "aws_route_table" "az_b_route_table" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = var.external_cidr_block
    gateway_id = aws_nat_gateway.nat_az_b.id
  }
}

resource "aws_route_table_association" "private_subnet_a_asso" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.az_a_route_table.id
}

resource "aws_route_table_association" "private_subnet_b_asso" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.az_b_route_table.id
}

resource "aws_eip" "nat_eip_a" {
  domain     = var.domain
  depends_on = [aws_internet_gateway.wordpress_igw]
}

resource "aws_eip" "nat_eip_b" {
  domain     = var.domain
  depends_on = [aws_internet_gateway.wordpress_igw]
}