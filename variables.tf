################################################################################
# variables.tf
################################################################################

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-2"
}

variable "vpc_id" {
  type        = string
  description = "The VPC to deploy into"
  default     = "vpc-025a976bcbce78ab9"
}

variable "private_subnet" {
  type        = map(string)
  description = "Private Subnets"
  default = {
    "eu-west-2a" = "10.0.1.0/24",
    "eu-west-2b" = "10.0.2.0/24",
    "eu-west-2c" = "10.0.3.0/24"
  }
}

variable "public_subnet" {
  type        = map(string)
  description = "Public Subnets"
  default = {
    "eu-west-2a" = "10.0.4.0/24",
    "eu-west-2b" = "10.0.5.0/24",
    "eu-west-2c" = "10.0.6.0/24"
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones used"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "subnet_id" {
  type    = string
  default = "aws_subnet.private.id"
}

variable "aws_internet_gateway" {
  type    = string
  default = "aws_internet_gateway.main"
}

variable "aws_eip" {
  type = string
  default = "aws_eip.main.id"
}

variable "cidr_block" {
  type        = string
  description = "CIDR Block to allow traffic via"
  default     = "0.0.0.0/0"
}

variable "security_group" {
  type        = string
  description = "Name of the EC2 Security Group"
  default     = "SG-App"
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = null
}
