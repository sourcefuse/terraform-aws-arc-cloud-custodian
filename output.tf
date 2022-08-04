output "bucket_id" {
  description = "Name of the bucket."
  value       = aws_s3_bucket.custodian_output.id
}

output "bucket_arn" {
  description = "ARN of the bucket."
  value       = aws_s3_bucket.custodian_output.arn
}

output "role_name" {
  description = "Name of the role created."
  value       = aws_iam_role.role.name
}

output "role_arn" {
  description = "ARN of the role created."
  value       = aws_iam_role.role.arn
}

output "sqs_arn" {
  description = "ARN of the SQS queue"
  value       = var.cloudtrail_sqs_enabled == true ? module.cloudtrail_sqs_queue[0].sqs_queue_arn : ""
}
