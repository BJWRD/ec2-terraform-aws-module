################################################################################
# vpc.tf
################################################################################

locals {
  subnet_tags = {
    private_subnet_tag = "Private-Subnet"
  }
}

#VPC 
############################################################
provider "aws" {
  region = var.region
}

# Determine all of the available availability zones in the current AWS region
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "main" {
  id   = var.vpc_id
  tags = merge(local.required_tags, { Name = "VPC" })
}

output "vpc" {
  value = data.aws_vpc.main.arn
}

#NAT gateway for the private subnet
data "aws_nat_gateway" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = merge(local.required_tags, { Name = "NAT-Gateway" })
}

# Route table for NAT Gateway
resource "aws_route_table" "main" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.cidr_block
    gateway_id = data.aws_nat_gateway.main.id
  }

  tags = merge(local.required_tags, { Name = "Route-Table" })
}

#Route table associations
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main[each.key].id
  for_each       = var.private_subnet
  route_table_id = aws_route_table.main.id
}

#Private subnet
resource "aws_subnet" "main" {
  for_each          = data.aws_availability_zones.available
  vpc_id            = data.aws_vpc.main.id
  cidr_block        = var.cidr_block
  availability_zone = each.key
  tags              = merge(local.required_tags, local.subnet_tags)
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