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

variable "cidr_block" {
  type = string
  default = "10.2.0.0/16"
}

variable "public_cidr_blocks" {
  type = list(string)
  default = [ "10.2.1.0/24", "10.2.2.0/24" ]
}

variable "private_cidr_blocks" {
  type = list(string)
  default = [ "10.2.3.0/24", "10.2.4.0/24" ]
}