variable "cidr_block" {
  type    = string
  default = "10.2.0.0/16"
}

variable "public_cidr_block_a" {
  type    = string
  default = "10.2.1.0/24"
}

variable "public_cidr_block_b" {
  type    = string
  default = "10.2.2.0/24"
}

variable "private_cidr_block_a" {
  type    = string
  default = "10.2.3.0/24"
}

variable "private_cidr_block_b" {
  type    = string
  default = "10.2.4.0/24"
}

variable "private_cidr_block_c" {
  type    = string
  default = "10.2.5.0/24"
}

variable "private_cidr_block_d" {
  type    = string
  default = "10.2.6.0/24"
}

variable "external_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "az_a" {
  type = string
}

variable "az_b" {
  type = string
}

variable "public_ip_map" {
  type    = bool
  default = true
}

variable "private_ip_map" {
  type    = bool
  default = false
}

variable "domain" {
  type    = string
  default = "vpc"
}

variable "dns_host" {
  type    = bool
  default = true
}