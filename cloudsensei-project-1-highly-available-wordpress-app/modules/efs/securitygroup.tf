resource "aws_security_group" "fs_security_group" {
  name   = var.name
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "allow_app_client_to_standby_fs" {
  type                     = var.traffic_type
  from_port                = var.fs_from_port
  to_port                  = var.fs_to_port
  protocol                 = var.protocol
  source_security_group_id = var.source_security_group_id
  security_group_id        = var.security_group_id
}