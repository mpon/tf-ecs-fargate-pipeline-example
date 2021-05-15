provider "aws" {
  version = "~> 2.70"
}

provider "github" {
  /*
    If github provider would be released 3.0.0 major version, you will have to modify version.
    ref: https://github.com/terraform-providers/terraform-provider-github/blob/master/CHANGELOG.md#290-june-29-2020
  */
  version = "= 2.9.0"
  owner   = "mpon"
}

provider "random" {
  version = "~> 3.0"
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    key = "terraform/prod/terraform.tfstate"
  }
}

data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_backend
    key    = "terraform/common/terraform.tfstate"
    region = data.aws_region.current.name
  }
}