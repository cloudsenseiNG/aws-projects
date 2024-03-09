variable "subnet_group_name" {
  type    = string
  default = "wordpress db subnet group"
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "engine" {
  type    = string
  default = "aurora-mysql"
}

variable "identifier" {
  type    = string
  default = "wp-aurora-mysql"
}

variable "instance_class" {
  type    = string
  default = "db.r5.large"
}

variable "rds_cluster_identifier" {
  type    = string
  default = "wordpress"
}

variable "engine_version" {
  type    = string
  default = "8.0.mysql_aurora.3.04.0"
}

variable "availability_zones" {
  type = list(string)
}

variable "database_name" {
  type    = string
  default = "wordpress"
}

variable "master_username" {
  type    = string
  default = "admin"
}

variable "master_password" {
  sensitive = true
  type      = string

}

variable "backup_retention_period" {
  type    = number
  default = 5
}

variable "preferred_backup_window" {
  type    = string
  default = "07:00-09:00"
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "name" {
  type    = string
  default = "WordPress DB Security Group"
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

variable "db_from_port" {
  type    = number
  default = 3306
}

variable "db_to_port" {
  type    = number
  default = 3306
}

variable "protocol" {
  type    = string
  default = "tcp"
}