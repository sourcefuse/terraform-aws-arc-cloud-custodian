variable "cloudtrail_enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "cloudtrail_s3_bucket_enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "cloudtrail_sqs_enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "custodian_files_path" {
  description = "Path to where the custodian files are located."
  default     = null
}

variable "custodian_templates_path" {
  description = "Path to where the custodian template files are located."
  default     = null
}

variable "name" {
  description = "Name of invocation."
}

variable "namespace" {
  description = "A namespace for all the resources to live in."
}

variable "region" {
  description = "AWS Region to create objects in."
}

variable "stage" {
  description = "Stage of pipeline (Eg. sbx, dev, staging, uat, prod)."
}

variable "template_file_vars" {
  description = "Variable name and value maps."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags to assign resources."
  type        = map(string)
}
