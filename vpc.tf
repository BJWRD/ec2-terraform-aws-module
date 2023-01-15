################################################################################
# vpc.tf
################################################################################

# VPC
provider "aws" {
  region = var.region
}

# Determine all of the available availability zones in the current AWS region
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["var"]
  }
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = merge(local.required_tags, { Name = "Internet-Gateway" })
}

# Elastic IP for NAT
resource "aws_eip" "main" {
  vpc = true
  depends_on = [var.aws_internet_gateway]
}

#NAT gateway for the public subnet
resource "aws_nat_gateway" "main" {
  allocation_id     = var.aws_eip
  for_each          = var.public_subnet
  subnet_id         = each.key
  depends_on        = [var.aws_internet_gateway]

  tags = merge(local.required_tags, { Name = "NAT-Gateway" })
}

# Route table for NAT Gateway
resource "aws_route_table" "main" {
  vpc_id   = var.vpc_id
  for_each = var.private_subnet

  route {
    cidr_block = var.cidr_block
    gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = merge(local.required_tags, { Name = "Route-Table" })
}

#Route table associations - Private
resource "aws_route_table_association" "private" {
  subnet_id      = each.key
  for_each       = var.private_subnet
  route_table_id = aws_route_table.main[each.key].id
}

#Route table associations - Public
resource "aws_route_table_association" "public" {
  subnet_id      = each.key
  for_each       = var.public_subnet
  route_table_id = aws_route_table.main[each.key].id
}

#Public subnet
resource "aws_subnet" "public" {
  for_each          = data.aws_availability_zones.available
  vpc_id            = data.aws_vpc.main.id
  cidr_block        = var.cidr_block
  availability_zone = each.key
  map_public_ip_on_launch = true
  tags              = merge(local.required_tags, { Name = "Public-Subnet" })
}

#Private subnet
resource "aws_subnet" "private" {
  for_each          = data.aws_availability_zones.available
  vpc_id            = data.aws_vpc.main.id
  cidr_block        = var.cidr_block
  availability_zone = each.key
  map_public_ip_on_launch = false
  tags              = merge(local.required_tags, { Name = "Private-Subnet" })
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