locals {
  env      = "prod"
  vpc_cidr = "10.10.0.0/16"
}

variable "remote_backend" {
  type        = string
  description = "Terraform Remote Backend to get remote state"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
