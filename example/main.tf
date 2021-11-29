terraform {
  required_version = "~> 1.0.5"
}

provider "aws" {
  region = "us-east-1"
}

module "cloud_custodian" {
  source = "../."

  name      = "tf-cloud-custodian"
  namespace = "refarch"
  region    = "us-east-1"
  stage     = "example"

  custodian_files_path = "${path.root}/files"


  tags      = {
    Module  = "terraform-aws-cloud-custodian"
    Example = "true"
  }
}
