provider "aws" {
  version = "~> 3.0"
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    key = "terraform/dev/terraform.tfstate"
  }
}
