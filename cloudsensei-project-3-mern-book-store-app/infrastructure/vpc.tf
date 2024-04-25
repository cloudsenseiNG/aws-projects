//This specifies the vpc environment
resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
}
//This deploys the public subnet
resource "aws_subnet" "public" {
  count = length(var.public_cidr_blocks)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_cidr_blocks[count.index]
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count = length(var.private_cidr_blocks)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_cidr_blocks[count.index]
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
}

//This creates the internet gateway for the VPC
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "this" {
  count = length(var.public_cidr_blocks)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.this.id
}

resource "aws_route_table" "nat" {
  count = length(var.private_cidr_blocks)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this[count.index].id
  }
}

resource "aws_route_table_association" "this" {
  count = length(var.private_cidr_blocks)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.nat.id
}

resource "aws_nat_gateway" "this" {
  count = length(var.private_cidr_blocks)
  allocation_id = aws_eip.this[count.index].id
  subnet_id = aws_subnet.public[count.index].id
  depends_on = [ aws_internet_gateway.gateway ]
}

resource "aws_eip" "this" {
  count = length(var.private_cidr_blocks)
  domain = "vpc"
  depends_on = [ aws_internet_gateway.gateway ]
}