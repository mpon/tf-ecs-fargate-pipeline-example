locals {
  env          = "prod"
  vpc_cidr     = "10.10.0.0/16"
  github_owner = "mpon"
  github_repo  = "rails-blog-example"
}

variable "remote_backend" {
  type        = string
  description = "S3 bucket that stores terraform.tfstate"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
