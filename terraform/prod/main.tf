provider "aws" {
  version = "~> 2.70"
  region  = "ap-northeast-1"
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    key    = "terraform/prod/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_backend
    key    = "terraform/common/terraform.tfstate"
    region = "ap-northeast-1"
  }
}