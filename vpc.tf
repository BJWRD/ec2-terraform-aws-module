################################################################################
# vpc.tf
################################################################################

# VPC
provider "aws" {
  region = var.region
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["var"]
  }
}

#Public subnet
resource "aws_subnet" "public" {
  for_each          = var.public_subnet
  vpc_id            = data.aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true #makes this a public subnet
  depends_on = [data.aws_vpc.main]

  tags              = merge(local.required_tags, { Name = "Public-Subnet" })
}

#Private subnet
resource "aws_subnet" "private" {
  for_each          = var.private_subnet
  vpc_id            = data.aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  map_public_ip_on_launch = false
  depends_on = [data.aws_vpc.main, aws_subnet.public]

  tags              = merge(local.required_tags, { Name = "Private-Subnet" })
}

#Internet Gateway for the Public Subnet
resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id
  depends_on = [data.aws_vpc.main, aws_subnet.public, aws_subnet.private]

  tags = merge(local.required_tags, { Name = "Internet-Gateway" })
}

#Route table for the Internet Gateway / Public Subnet
resource "aws_route_table" "IGW" {
  vpc_id   = var.vpc_id
  for_each = var.public_subnet
  depends_on = [data.aws_vpc.main, aws_internet_gateway.main]

  # NAT Rule
  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.required_tags, { Name = "Route-Table" })
}

#Route table associations - Public
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public[each.key].id
  for_each       = var.public_subnet
  route_table_id = aws_route_table.IGW[each.key].id
  depends_on = [data.aws_vpc.main, aws_subnet.public, aws_subnet.private, aws_route_table.IGW]
}

# Elastic IP for NAT Gateway
resource "aws_eip" "main" {
  vpc = true
  depends_on = [aws_route_table_association.public]

  tags = merge(local.required_tags, { Name = "Elastic-IP" })
}

#NAT Gateway for the Public Subnet
resource "aws_nat_gateway" "main" {
  allocation_id     = aws_eip.main.id
  for_each          = var.public_subnet
  subnet_id         = aws_subnet.public[each.key].id
  depends_on = [aws_eip.main]

  tags = merge(local.required_tags, { Name = "NAT-Gateway" })
}

#Route table for the NAT Gateway / Private Subnet
resource "aws_route_table" "NG" {
  vpc_id   = var.vpc_id
  for_each = var.private_subnet
  depends_on = [aws_nat_gateway.main]

  # NAT Rule
  route {
    cidr_block = var.cidr_block
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = merge(local.required_tags, { Name = "Route-Table" })
}

#Route table associations - Private
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private[each.key].id
  for_each       = var.private_subnet
  route_table_id = aws_route_table.NG[each.key].id
  depends_on = [aws_route_table.NG]
}

#EC2 Instance Security Group
############################################################
resource "aws_security_group" "main" {
  name        = var.security_group
  description = "Security Group for EC2 Host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
    description = "Allows SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
    description = "Allows HTTP access"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
    description = "Allows HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }

  tags = merge(local.required_tags, { Name = "EC2-Security_Group" })
}
