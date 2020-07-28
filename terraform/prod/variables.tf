locals {
  env = "prod"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
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
