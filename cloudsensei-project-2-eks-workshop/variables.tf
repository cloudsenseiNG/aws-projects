variable "cluster_name" {
  type    = string
  default = "eks-workshop"
}

variable "cluster_version" {
  description = "EKS cluster version."
  type        = string
  default     = "1.27"
}

variable "ami_release_version" {
  description = "Default EKS AMI release version for node groups"
  type        = string
  default     = "1.27.3-20230816"
}

variable "vpc_cidr" {
  description = "Defines the CIDR block used on Amazon VPC created for Amazon EKS."
  type        = string
  default     = "10.42.0.0/16"
}

# variable "bucket" {
#   type        = string
#   description = "The name of the S3 bucket."
# }

# variable "backend_bucket_key" {
#   type        = string
#   description = "The key in the backend bucket."
# }

# variable "region" {
#   type        = string
#   description = "The AWS region where resources will be provisioned."
# }

# variable "dynamodb_table" {
#   type        = string
#   description = "The name of the DynamoDB table."
# }

# variable "billing_mode" {
#   type        = string
#   description = "The billing mode for DynamoDB (e.g., PROVISIONED, PAY_PER_REQUEST)."
# }

# variable "hash_key" {
#   type        = string
#   description = "The hash key for the DynamoDB table."
# }

# variable "attribute_name" {
#   type        = string
#   description = "The name of the attribute in the DynamoDB table."
# }

# variable "attribute_type" {
#   type        = string
#   description = "The type of the attribute in the DynamoDB table."
# }
