output "cache_security_group_id" {
  value = aws_security_group.cache_security_group.id
}

output "cache_cluster" {
  value = aws_elasticache_cluster.wp_db_cache_cluster
}