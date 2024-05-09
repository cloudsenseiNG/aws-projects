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

# tflint-ignore: terraform_unused_declarations
# variable "cluster_security_group_id" {
#   description = "EKS cluster security group ID"
#   type        = any
# }

# # tflint-ignore: terraform_unused_declarations
# variable "addon_context" {
#   description = "Addon context that can be passed directly to blueprints addon modules"
#   type        = any
# }

# tflint-ignore: terraform_unused_declarations
# variable "tags" {
#   description = "Tags to apply to AWS resources"
#   type        = any
# }

# tflint-ignore: terraform_unused_declarations
# variable "resources_precreated" {
#   description = "Have expensive resources been created already"
#   type        = bool
# }

