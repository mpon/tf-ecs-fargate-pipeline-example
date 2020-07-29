locals {
  env = "prod"
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "github_owner" {
  type    = string
  default = "mpon"
}

variable "github_repo" {
  type    = string
  default = "rails-blog-example"
}

variable "remote_backend" {
  type        = string
  description = "S3 bucket that stores terraform.tfstate"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}
