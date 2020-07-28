module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.env}-vpc"
  cidr = var.vpc_cidr
  azs  = var.azs
  private_subnets = [
    cidrsubnet(var.vpc_cidr, 4, 0),
    cidrsubnet(var.vpc_cidr, 4, 1),
    cidrsubnet(var.vpc_cidr, 4, 2),
  ]
  public_subnets = [
    cidrsubnet(var.vpc_cidr, 4, 3),
    cidrsubnet(var.vpc_cidr, 4, 4),
    cidrsubnet(var.vpc_cidr, 4, 5),
  ]
  database_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 96),
    cidrsubnet(var.vpc_cidr, 8, 97),
    cidrsubnet(var.vpc_cidr, 8, 98),
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dhcp_options    = true
  enable_dns_hostnames   = true

  enable_s3_endpoint                   = true
  ecr_dkr_endpoint_private_dns_enabled = true
  ecr_dkr_endpoint_security_group_ids  = [aws_security_group.private.id]

  tags = {
    Environment = local.env
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
