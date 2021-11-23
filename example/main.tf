terraform {
  required_version = "~> 1.0.5"
}

provider "aws" {
  region = "us-east-1"
}

module "cloud_custodian" {
  source = "../."

  name      = "cloud_custodian"
  namespace = "refarch"
  region    = "us-east-1"
  stage     = "dev"

  tags      = {
    Module = "terraform-aws-cloud-custodian"
  }
}
