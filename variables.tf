################################################################################
# variables.tf
################################################################################

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_id" {
  description = "The VPC to deploy into"
  type        = string
  default     = "vpc-025a976bcbce78ab9"
}

variable "private_subnet" {
  description = "A list of private subnets inside the VPC"
  type        = map(string)
  default = {
    "eu-west-2a" = "10.0.1.0/24",
    "eu-west-2b" = "10.0.2.0/24",
    "eu-west-2c" = "10.0.3.0/24"
  }
}

variable "public_subnet" {
  description = "A list of public subnets inside the VPC"
  type        = map(string)
  default = {
    "eu-west-2a" = "10.0.4.0/24",
    "eu-west-2b" = "10.0.5.0/24",
    "eu-west-2c" = "10.0.6.0/24"
  }
}

variable "availability_zones" {
  description = "A list of Availability Zones used"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "aws_internet_gateway" {
  description = "The AWS Internet Gateway resource"
  type    = string
  default = "aws_internet_gateway.main"
}

variable "aws_eip" {
  description = "The EIP ID"
  type = string
  default = "aws_eip.main.id"
}

variable "cidr_block" {
  description = "CIDR Block to allow traffic via"
  type        = string
  default     = "0.0.0.0/0"
}

variable "security_group" {
  description = "Name of the EC2 Security Group"
  type        = string
  default     = "SG-App"
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = null
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type    = string
  default = "aws_subnet.private.id"
}
