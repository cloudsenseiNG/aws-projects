variable "name" {
  type    = string
  default = "wordpress-lb"
}

variable "internal" {
  type    = bool
  default = false
}

variable "load_balancer_type" {
  type    = string
  default = "application"
}

variable "subnets" {
  type = list(string)
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "security_groups" {
  type = list(string)
}

variable "target_group_name" {
  type    = string
  default = "wordpress-target-group"
}

variable "target_group_port" {
  type    = number
  default = 80
}

variable "listener_port" {
  type    = number
  default = 80
}

variable "protocol" {
  type    = string
  default = "HTTP"
}

variable "vpc_id" {
  type = string
}

variable "target_type" {
  type    = string
  default = "instance"
}

variable "action_type" {
  type    = string
  default = "forward"
}

variable "listener_priority" {
  type    = number
  default = 1
}

variable "security_group_vpc_id" {
  type = string
}