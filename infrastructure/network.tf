locals {
  public_az_count     = 2
  db_az_count         = 2
  app_az_count        = 1
  db_cidr_newbits     = 3
  db_cidr_netnum_base = 6
}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "Main" {
  cidr_block           = "10.0.0.0/24"
  tags                 = local.default_tags
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.Main.id
  count             = local.public_az_count
  cidr_block        = cidrsubnet(aws_vpc.Main.cidr_block, local.public_az_count, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(local.default_tags, tomap({ "Name" : "${local.prefix}-public-${count.index + 1}" }))
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.Main.id
  count             = local.app_az_count
  cidr_block        = cidrsubnet(aws_vpc.Main.cidr_block, local.public_az_count, length(aws_subnet.public.*.id) + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(local.default_tags, tomap({ "Name" : "${local.prefix}-private-${count.index + 1}" }))
}
resource "aws_subnet" "private-db" {
  vpc_id            = aws_vpc.Main.id
  count             = local.db_az_count
  cidr_block        = cidrsubnet(aws_vpc.Main.cidr_block, local.db_cidr_newbits, local.db_cidr_netnum_base + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(local.default_tags, tomap({ "Name" : "${local.prefix}-private-db-${count.index + 1}" }))
}

#for public subnet - internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.Main.id
  tags   = local.default_tags
}
#elastic ip for NAT gateway
resource "aws_eip" "nat-eip" {
  vpc  = true #if the EIP is in the VPC
  tags = local.default_tags
}
#for private subnet - NAT gateway
resource "aws_nat_gateway" "nat" {
  subnet_id     = element(aws_subnet.public.*.id, 0)
  allocation_id = aws_eip.nat-eip.id
  tags          = local.default_tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = merge(local.default_tags, tomap({ "Name" : "${local.prefix}-public-rt" }))
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(local.default_tags, tomap({ "Name" : "${local.prefix}-private-rt" }))
}
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.Main.id
  tags   = merge(local.default_tags, tomap({ "Name" : "${local.prefix}-db" }))
}


resource "aws_route_table_association" "public-a" {
  count          = local.public_az_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private-a" {
  count          = local.app_az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "db-a" {
  count          = local.db_az_count
  subnet_id      = element(aws_subnet.private-db.*.id, count.index)
  route_table_id = aws_route_table.db.id
}


resource "aws_db_subnet_group" "box-subnet-group" {
  count      = local.db_az_count
  subnet_ids = aws_subnet.private-db.*.id
  tags       = merge(local.default_tags, tomap({ "Name" : "${local.prefix}-database-subnets" }))
}