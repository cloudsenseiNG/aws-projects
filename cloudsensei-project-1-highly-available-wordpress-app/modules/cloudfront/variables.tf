variable "Environment" {
  type    = string
  default = "Prod"
}

variable "origin_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "allowed_methods" {
  type    = list(string)
  default = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}


variable "cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "min_ttl" {
  type    = number
  default = 0
}

variable "default_ttl" {
  type    = number
  default = 3600
}

variable "max_ttl" {
  type    = number
  default = 86400
}

variable "restriction_type" {
  type    = string
  default = "whitelist"
}

variable "locations" {
  type    = list(string)
  default = ["US", "CA", "GB", "DE", "NG"]
}

variable "cloudfront_default_certificate" {
  type    = bool
  default = true
}

variable "cookies_forward_value" {
  type    = string
  default = "none"
}

variable "query_string" {
  type    = bool
  default = false
}

variable "viewer_protocol_policy" {
  type    = string
  default = "allow-all"
}

variable "origin_protocol_policy" {
  type    = string
  default = "match-viewer"
}

variable "origin_ssl_protocols" {
  type    = list(string)
  default = ["TLSv1.2"]
}