variable "cache_name" {
  type    = string
  default = "cache-subnet"
}

variable "cache_subnets" {
  type = list(string)
}

variable "cluster_id" {
  type    = string
  default = "memcached-cluster"
}

variable "cluster_engine" {
  type    = string
  default = "memcached"
}

variable "node_type" {
  type    = string
  default = "cache.t2.small"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "parameter_group_name" {
  type    = string
  default = "default.memcached1.6"
}

variable "availability_zones" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "name" {
  type    = string
  default = "WordPress Cache Security Group"
}

variable "vpc_id" {
  type = string
}

variable "traffic_type" {
  type    = string
  default = "ingress"
}

variable "cache_from_port" {
  type    = number
  default = 11211
}

variable "cache_to_port" {
  type    = number
  default = 11211
}

variable "protocol" {
  type    = string
  default = "tcp"
}

variable "security_group_id" {
  description = "Standby Security Group ID"
  type        = string
}

variable "source_security_group_id" {
  description = "Source Security Group ID"
  type        = string
}


