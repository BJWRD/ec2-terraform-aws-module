################################################################################
# vpc.tf
################################################################################

locals {
  required_tags = {
    project     = "ec2-terraform-aws-module"
    environment = "dev"
  }

  ingress_rules = [{
    port        = 8080
    description = "Allow HTTP access"
    },
    {
      port        = 443
      description = "Allow HTTPS access"
    },
    {
      port        = 22
      description = "Allow SSH access"
  }]

  egress_rules = [{
    port        = 0
    description = "All all Egress traffic"
  }]
}

# VPC
provider "aws" {
  region = var.region
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["VPC-Dev"]
  }
}

#Public subnet
resource "aws_subnet" "public" {
  for_each                = var.public_subnet
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true #makes this a public subnet

  tags = merge(local.required_tags, { Name = "Public-Subnet" })
}

#Private subnet
resource "aws_subnet" "private" {
  for_each                = var.private_subnet
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(local.required_tags, { Name = "Private-Subnet" })
}

#Internet Gateway for the Public Subnet
resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = merge(local.required_tags, { Name = "Internet-Gateway" })
}

#Route table for the Internet Gateway / Public Subnet
resource "aws_route_table" "IGW" {
  vpc_id   = var.vpc_id
  for_each = var.public_subnet

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
}

# Elastic IP for NAT Gateway
resource "aws_eip" "main" {
  vpc      = true
  for_each = var.private_subnet

  tags = merge(local.required_tags, { Name = "Elastic-IP" })
}

#NAT Gateway for the Public Subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main[each.key].id
  for_each      = var.public_subnet
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(local.required_tags, { Name = "NAT-Gateway" })
}

#Route table for the NAT Gateway / Private Subnet
resource "aws_route_table" "NG" {
  vpc_id   = var.vpc_id
  for_each = var.private_subnet

  # NAT Rule
  route {
    cidr_block     = var.cidr_block
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = merge(local.required_tags, { Name = "Route-Table" })
}

#Route table associations - Private
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private[each.key].id
  for_each       = var.private_subnet
  route_table_id = aws_route_table.NG[each.key].id
}

#EC2 Instance Security Group
############################################################
resource "aws_security_group" "main" {
  name        = var.security_group
  description = "Security Group for EC2 Host"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]

    }
  }

  dynamic "egress" {
    for_each = local.egress_rules

    content {
      description = egress.value.description
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]

    }
  }

  tags = merge(local.required_tags, { Name = "EC2-Security_Group" })
}
