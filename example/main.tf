terraform {
  required_version = "~> 1.0.5"
}

provider "aws" {
  region = "us-east-1"
}

/////////////////////////////////////////////////////////////// START OF TESTING ///////////////////////////////////////////////////////////////
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_assume" {
  name               = "lambda-assume-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_policy" "ec2" {
  name        = "cloud-custodian-allow-ec2-management"
  description = "Cloud Custodian EC2 policy."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_lambda_basic_execution_role" {
  role       = aws_iam_role.lambda_assume.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.lambda_assume.name
  policy_arn = aws_iam_policy.ec2.arn
}

/////////////////////////////////////////////////////////////// END OF TESTING ///////////////////////////////////////////////////////////////

module "cloud_custodian" {
  source = "../."

  name      = "tf-cloud-custodian"
  namespace = "refarch"
  region    = "us-east-1"
  stage     = "example"

  custodian_files_path     = "${path.root}/files"
  custodian_templates_path = "${path.root}/templates"

  template_file_vars = {
    EC2_TAG_ROLE = module.cloud_custodian.role_arn
  }

  tags = {
    Module  = "terraform-aws-cloud-custodian"
    Example = "true"
  }
}
