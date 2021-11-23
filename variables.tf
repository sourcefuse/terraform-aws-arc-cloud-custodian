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

variable "namespace" {
  description = "A namespace for all the resources to live in."
}

variable "stage" {
  description = "A development stage (Eg. dev, stg, prod)."
}

variable "name" {
  description = "Name of invocation."
}

variable "region" {
  description = "AWS Region to create objects in."
}

variable "tags" {
  description = "Additional tags to assign resources."
  type        = map(any)
}
