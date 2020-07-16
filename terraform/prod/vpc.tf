module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.env}-vpc"
  cidr = local.vpc_cidr
  azs  = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets = [
    cidrsubnet(local.vpc_cidr, 4, 0),
    cidrsubnet(local.vpc_cidr, 4, 1),
    cidrsubnet(local.vpc_cidr, 4, 2),
  ]
  public_subnets = [
    cidrsubnet(local.vpc_cidr, 4, 3),
    cidrsubnet(local.vpc_cidr, 4, 4),
    cidrsubnet(local.vpc_cidr, 4, 5),
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dhcp_options    = true
  enable_dns_hostnames   = true

  tags = {
    Environment = local.env
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
