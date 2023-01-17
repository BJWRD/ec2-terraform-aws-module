################################################################################
# ec2.tf
################################################################################

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                   = var.ec2_name
  ami                    = var.ami_type
  instance_type          = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids
  for_each                = var.private_subnet
  subnet_id              = aws_subnet.private[each.key].id
  
  tags = merge(local.required_tags, { Name = "EC2-Instance" })
}