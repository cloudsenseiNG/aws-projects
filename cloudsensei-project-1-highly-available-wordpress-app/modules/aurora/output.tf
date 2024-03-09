output "db_security_group_id" {
  value = aws_security_group.db_security_group.id
}

output "rds_cluster_instances" {
  value = aws_rds_cluster_instance.cluster_instances
}

output "rds_endpoint" {
  value = aws_rds_cluster.default.endpoint
}

output "rds_database_name" {
  value = aws_rds_cluster.default.database_name
}

output "rds_password" {
  value = aws_rds_cluster.default.master_password
}

output "rds_username" {
  value = aws_rds_cluster.default.master_username
}