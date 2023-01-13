################################################################################
# ec2.tf
################################################################################

locals {
  name_suffix = "ec2-terraform-aws-module-Dev-Environment"
}

locals {
  required_tags = {
    project     = "ec2-terraform-aws-module"
    environment = "Dev"
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "EC2"

  ami                    = "ami-0b5eea76982371e91"
  instance_type          = "t2.nano"
  monitoring             = true
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = aws_subnet.main[each.key].id
  #key_name - allows private key (.pem file) to be used with ec2 instance
  key_name = "terraform"

  tags = merge(local.required_tags, { Name = "EC2-Instance" })
}
