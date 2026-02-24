locals {
  vpc_id = var.create_vpc ? aws_vpc.this[0].id : null
}

resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "public" {
  for_each = {
    for idx, subnet in var.public_subnets :
    idx => subnet
  }

  vpc_id                  = local.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  for_each = {
    for idx, subnet in var.private_subnets :
    idx => subnet
  }

  vpc_id            = local.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
}

resource "aws_internet_gateway" "this" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = local.vpc_id
}

resource "aws_eip" "nat" {
  count  = length(var.private_subnets) > 0 ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  count         = length(var.private_subnets) > 0 ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.public)[0].id

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets) > 0 ? 1 : 0
  vpc_id = local.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[0].id
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}