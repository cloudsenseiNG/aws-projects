resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  engine             = var.engine
  identifier         = "${var.identifier}-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = var.instance_class
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = var.rds_cluster_identifier
  db_subnet_group_name    = aws_db_subnet_group.wordpress_db_subnet_group.name
  engine                  = var.engine
  engine_version          = var.engine_version
  availability_zones      = var.availability_zones
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  vpc_security_group_ids  = var.vpc_security_group_ids
}