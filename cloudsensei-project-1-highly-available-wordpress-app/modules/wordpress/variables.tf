variable "name_prefix" {
  type    = string
  default = "launch_template"
}

variable "image_id" {
  type = string
}

variable "iam_arn" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "user_data" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "asg_name" {
  type    = string
  default = "wordpress_asg"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "vpc_zone_identifier" {
  type = list(string)
}

variable "target_group_arns" {
  type = list(string)
}

variable "template_version" {
  type    = string
  default = "$Default"
}

variable "security_group_vpc_id" {
  type = string
}