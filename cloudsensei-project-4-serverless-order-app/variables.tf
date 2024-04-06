variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Default region of the AWS provider"
}

variable "crud_operation" {
  type = list(string)
  default = ["create", "read", "update", "delete"]
}

variable "route_key" {
  type    = list(string)
  default = ["POST /items", "GET /items", "GET /items/{id}", "PUT /items/{id}", "DELETE /items/{id}"]
}

variable "api_name" {
  type    = string
  default = "OrderApi"
}

variable "protocol_type" {
  type    = string
  default = "HTTP"
}

variable "allow_methods" {
  type    = list(string)
  default = ["POST", "GET", "UPDATE", "DELETE"]
}

variable "allow_headers" {
  type    = list(string)
  default = ["X-Forwarded-For"]
}

variable "allow_origins" {
  type    = list(string)
  default = ["*"]
}

variable "max_age" {
  type    = number
  default = 600
}

variable "integration_type" {
  type    = string
  default = "AWS_PROXY"
}

variable "connection_type" {
  type    = string
  default = "INTERNET"
}

variable "integration_method" {
  type    = string
  default = "POST"
}

variable "passthrough_behavior" {
  type    = string
  default = "WHEN_NO_MATCH"
}

variable "payload_format_version" {
  type    = string
  default = "2.0"
}

variable "auth_name" {
  type = string
  default = "MyCognitoAuthorizer"
}

variable "authorizer_type" {
  type = string
  default = "JWT"
}

variable "runtime" {
  type = string
  default = "python3.10"
}