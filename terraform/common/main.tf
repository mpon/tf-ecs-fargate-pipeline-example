provider "aws" {
  version = "~> 2.70"
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    key = "terraform/common/terraform.tfstate"
  }
}
