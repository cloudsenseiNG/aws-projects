locals {
  availability_zone_a = data.aws_availability_zones.availability_zones.names[0]
  availability_zone_b = data.aws_availability_zones.availability_zones.names[1]
}

module "app" {
  source = "./modules/wordpress"

  instance_type          = var.app_instance_type
  image_id               = data.aws_ami.amazon_linux_2_latest.id
  vpc_security_group_ids = ["${module.app.app_security_group_id}"]
  user_data = base64encode("${templatefile("${path.module}/scripts/init-aml2.sh", {
    DB_HOST     = "${module.database.rds_endpoint}"
    DB_NAME     = "${module.database.rds_database_name}"
    DB_PASSWORD = "${module.database.rds_password}"
    DB_USER     = "${module.database.rds_username}"
    EFS_ID      = "${module.filesystem.efs_id}"
  })}")

  target_group_arns     = [module.loadbalancer.target_group_arn]
  vpc_zone_identifier   = [module.vpc.private_subnet_a, module.vpc.private_subnet_b]
  security_group_vpc_id = module.vpc.vpc_id
  iam_arn               = aws_iam_instance_profile.instance_profile.arn

  depends_on = [module.database.rds_cluster_instances, module.filesystem.efs_filesystem, module.cache.cache_cluster]
}

module "database" {
  source = "./modules/aurora"

  master_username          = var.db_username
  master_password          = var.db_password
  vpc_security_group_ids   = [module.database.db_security_group_id]
  source_security_group_id = module.app.app_security_group_id
  subnet_ids               = [module.vpc.private_subnet_c, module.vpc.private_subnet_d]
  availability_zones       = [local.availability_zone_a, local.availability_zone_b]
  vpc_id                   = module.vpc.vpc_id
  security_group_id        = module.database.db_security_group_id
}

module "cache" {
  source = "./modules/elasticache"

  security_group_id        = module.cache.cache_security_group_id
  source_security_group_id = module.app.app_security_group_id
  security_group_ids       = [module.cache.cache_security_group_id]
  cache_subnets            = [module.vpc.private_subnet_c, module.vpc.private_subnet_d]
  vpc_id                   = module.vpc.vpc_id
  availability_zones       = [local.availability_zone_a, local.availability_zone_b]
}

module "filesystem" {
  source = "./modules/efs"

  subnet_a                 = module.vpc.private_subnet_c
  subnet_b                 = module.vpc.private_subnet_d
  vpc_id                   = module.vpc.vpc_id
  security_group_id        = module.filesystem.fs_security_group_id
  source_security_group_id = module.app.app_security_group_id
  security_groups          = [module.filesystem.fs_security_group_id]
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  subnets               = [module.vpc.public_subnet_a, module.vpc.public_subnet_b]
  security_groups       = ["${module.loadbalancer.loadbalancer_security_group_id}"]
  vpc_id                = module.vpc.vpc_id
  security_group_vpc_id = module.vpc.vpc_id
}

module "cloudfront" {
  source = "./modules/cloudfront"

  domain_name = module.loadbalancer.loadbalancer_dns
  origin_id   = module.loadbalancer.loadbalancer_dns
}


module "vpc" {
  source = "./modules/vpc"

  az_a = local.availability_zone_a
  az_b = local.availability_zone_b
}
