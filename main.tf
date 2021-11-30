###################################################
## cloudtrail
###################################################
module "cloudtrail" {
  source  = "git::https://github.com/cloudposse/terraform-aws-cloudtrail.git?ref=0.20.1"
  enabled = var.cloudtrail_enabled

  namespace                     = var.namespace
  stage                         = var.stage
  name                          = var.name
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_logging                = true
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

  force_destroy = true

  namespace = var.namespace
  stage     = var.stage
  name      = "${var.name}-cloudtrail-logs"

  tags = merge(local.tags, tomap({
    Name = "${var.name}-cloudtrail-logs"
  }))
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

// TODO - remove if determine not needed
module "cloudtrail_sqs_queue" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-sqs.git?ref=v3.1.0"
  count  = var.cloudtrail_sqs_enabled == true ? 1 : 0

  name = "${var.namespace}-${var.stage}-${var.region}-${var.name}-sqs"

  tags = merge(local.tags, tomap({
    Name = "${var.namespace}-${var.stage}-${var.region}-${var.name}-sqs"
  }))
}

###################################################
## iam
###################################################
resource "aws_iam_role" "role" {
  name = "${var.name}-role"
  path = "/"

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

  tags = merge(local.tags, tomap({
    Name = "${var.name}-role"
  }))
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

  tags = merge(local.tags, tomap({
    Name = "${var.region}-${var.name}-s3-policy"
  }))
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
  count = var.cloudtrail_sqs_enabled == true ? 1 : 0

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

###################################################
## cloud custodian
###################################################
resource "local_file" "cc_saved" {
  for_each = try(fileset(var.custodian_templates_path, "**.tpl"), {})

  content  = templatefile("${var.custodian_templates_path}/${each.value}", var.template_file_vars)
  filename = "${var.custodian_files_path}/${trimsuffix(each.value, ".tpl")}"
}

resource "null_resource" "run_custodian" {
  for_each = try(fileset(var.custodian_files_path, "**.yml"), {})

  triggers = {
    always = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
pip install c7n;
custodian run -s s3://${aws_s3_bucket.custodian_output.bucket} ${abspath(var.custodian_files_path)}/${each.value}
EOF
    environment = {
      AWS_DEFAULT_REGION = var.region
    }
  }
}
