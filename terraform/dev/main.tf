provider "aws" {
  version = "~> 2.70"
  region  = "ap-northeast-1"
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    key    = "terraform/dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
