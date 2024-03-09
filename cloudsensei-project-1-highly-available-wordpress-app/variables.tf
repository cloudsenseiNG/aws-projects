variable "app_instance_type" {
  type        = string
  description = "The type of instance for the application."
}

variable "db_username" {
  type        = string
  description = "The username for accessing the database."
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "The password for accessing the database."
}

variable "backend_bucket" {
  type        = string
  description = "The name of the S3 bucket."
}

variable "object_bucket" {
  type = string
}
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

variable "email_address" {
  type    = list(string)
  description = "The email of the subscriber"
  default = [""]
}