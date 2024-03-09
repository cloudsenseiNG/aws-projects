variable "name" {
  type    = string
  default = "WordPress FS Security Group"
}

variable "vpc_id" {
  type = string
}

variable "traffic_type" {
  type    = string
  default = "ingress"
}

variable "source_security_group_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "fs_from_port" {
  type    = number
  default = 2049
}

variable "fs_to_port" {
  type    = number
  default = 2049
}

variable "protocol" {
  type    = string
  default = "tcp"
}

variable "creation_token" {
  type    = string
  default = "wordpress-filesystem"
}

variable "transition_to_ia" {
  type    = string
  default = "AFTER_30_DAYS"
}

variable "throughput_mode" {
  type    = string
  default = "elastic"
}

variable "subnet_a" {
  type = string
}

variable "subnet_b" {
  type = string
}

variable "security_groups" {
  type = list(string)
}