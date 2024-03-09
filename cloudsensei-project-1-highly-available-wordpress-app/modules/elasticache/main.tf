resource "aws_elasticache_subnet_group" "wp_db_cache_subnet" {
  name       = var.cache_name
  subnet_ids = var.cache_subnets
}

resource "aws_elasticache_cluster" "wp_db_cache_cluster" {
  cluster_id                   = var.cluster_id
  engine                       = var.cluster_engine
  node_type                    = var.node_type
  num_cache_nodes              = var.node_count
  parameter_group_name         = var.parameter_group_name
  preferred_availability_zones = var.availability_zones
  subnet_group_name            = aws_elasticache_subnet_group.wp_db_cache_subnet.name
  security_group_ids           = var.security_group_ids
}