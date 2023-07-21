resource "aws_vpc" "wp_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.wp_vpc.id
  tags = {
    Name = "${var.environment}-${var.project}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.wp_vpc.id
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-${var.project}-public${count.index}"
  }
}

resource "aws_subnet" "private" {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.wp_vpc.id
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, "${local.subnet_count + count.index}")
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.environment}-${var.project}-private${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.wp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.environment}-${var.project}-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.wp_vpc.id
  tags = {
    Name = "${var.environment}-${var.project}-private"
  }
}
resource "aws_route_table_association" "public" {
  count          = local.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = local.subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
resource "aws_nat_gateway" "nat-gw" {
  count         = var.enable_natgw ? 1 : 0
  allocation_id = aws_eip.eip[0].id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.environment}-${var.project}"
  }
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_eip" "eip" {
  count = var.enable_natgw ? 1 : 0
  domain   = "vpc"
  tags = {
    Name = "${var.environment}-${var.project}"
  }
}

resource "aws_route" "nat_on" {
  count                  = var.enable_natgw ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gw[0].id
  depends_on             = [aws_route_table.private]
}
