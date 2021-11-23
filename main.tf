module "cloudtrail" {
  source  = "git::https://github.com/cloudposse/terraform-aws-cloudtrail.git?ref=0.20.1"
  enabled = var.cloudtrail_enabled

  namespace                     = var.namespace
  stage                         = var.stage
  name                          = var.name
  enable_log_file_validation    = "true"
  include_global_service_events = "true"
  is_multi_region_trail         = "false"
  enable_logging                = "true"
  s3_bucket_name                = module.cloudtrail_s3_bucket.bucket_id

  event_selector = [
    {
      read_write_type           = "All"
      include_management_events = true

      data_resource = [{
        type   = "AWS::Lambda::Function"
        values = ["arn:aws:lambda"]
      }]
    },
  ]

  tags = merge(local.tags, tomap({
    Name = "${var.namespace}-${var.stage}-${var.name}-cloudtrail"
  }))
}

module "cloudtrail_s3_bucket" {
  source  = "git::https://github.com/cloudposse/terraform-aws-cloudtrail-s3-bucket.git?ref=0.23.1"
  enabled = var.cloudtrail_s3_bucket_enabled

  namespace = var.namespace
  stage     = var.stage
  name      = "${var.name}-cloudtrail-logs"
}

resource "aws_s3_bucket" "custodian_output" {
  bucket = "${var.namespace}-${var.stage}-${var.region}-${var.name}-custodian-output"

  force_destroy = true

  versioning {
    enabled = true
  }

  tags = merge(local.tags, tomap({
    Name = "${var.name}-custodian-output"
  }))
}

module "cloudtrail_sqs_queue" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-sqs.git?ref=v3.1.0"
  name   = "${var.namespace}-${var.stage}-${var.region}-${var.name}-sqs"

  tags = merge(local.tags, tomap({
    Name = "${var.namespace}-${var.stage}-${var.region}-${var.name}-sqs"
  }))
}

resource "aws_iam_role" "role" {
  name = "${var.name}-role"
  path = "/${var.namespace}/${var.stage}/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
      }
  ]
}
EOF
}

resource "aws_iam_policy" "custodian_output_s3_policy" {
  name        = "${var.region}-${var.name}-s3-policy"
  path        = "/${var.namespace}/${var.stage}/"
  description = "Allow Custodian to Write to S3 Bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
		{
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["${aws_s3_bucket.custodian_output.arn}"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": ["${aws_s3_bucket.custodian_output.arn}/*"]
        }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_output" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.custodian_output_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudtrail" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudTrailReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatchlogs" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "iam" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "tags" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/ResourceGroupsandTagEditorReadOnlyAccess"
}
