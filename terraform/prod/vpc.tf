module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.env}-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs
  private_subnets = [
    cidrsubnet(var.vpc_cidr, 3, 0),
    cidrsubnet(var.vpc_cidr, 3, 1),
  ]
  public_subnets = [
    cidrsubnet(var.vpc_cidr, 3, 2),
    cidrsubnet(var.vpc_cidr, 3, 3),
  ]
  database_subnets = [
    cidrsubnet(var.vpc_cidr, 3, 4),
    cidrsubnet(var.vpc_cidr, 3, 5),
  ]

  enable_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_s3_endpoint                   = true
  enable_ecr_api_endpoint              = true
  enable_ecr_dkr_endpoint              = true
  ecr_dkr_endpoint_private_dns_enabled = true
  ecr_dkr_endpoint_security_group_ids  = [aws_security_group.private.id]

  tags = {
    Environment = local.env
  }
}
