###########################################
## defaults / versions / providers
###########################################
terraform {
  required_version = "~> 1.3"

  #   backend "s3" {
  #     region         = "us-east-1"
  #     key            = "terraform-aws-cloud-custodian/terraform.tfstate"
  #     bucket         = "sf-ref-arch-terraform-state-dev"
  #     dynamodb_table = "sf_ref_arch_terraform_state_dev"
  #     encrypt        = true
  #   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}
