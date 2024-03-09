variable "region" {
  type        = string
  description = "The AWS region where resources will be provisioned."
}

variable "dynamodb_table" {
  type        = string
  description = "The name of the DynamoDB table."
}

variable "billing_mode" {
  type        = string
  description = "The billing mode for DynamoDB (e.g., PROVISIONED, PAY_PER_REQUEST)."
}

variable "hash_key" {
  type        = string
  description = "The hash key for the DynamoDB table."
}

variable "attribute_name" {
  type        = string
  description = "The name of the attribute in the DynamoDB table."
}

variable "attribute_type" {
  type        = string
  description = "The type of the attribute in the DynamoDB table."
}

variable "bucket" {
  type        = string
  description = "The name of the S3 bucket."
}
