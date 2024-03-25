#################################################  module config  #################################################
# In module parameters recommend use terraform variables, because:
# - values can be environment dependent
# - this ComponentName.tf file - is more for component logic description, not for values definition
# - it is better to store vars values in one or two places(<ENV>.tfvars file and variables.tf)

resource "aws_rds_global_cluster" "default" {
  global_cluster_identifier = "${var.prefix}-${var.stack}-db-cl-global-${var.ENV}"
  engine                    = var.db_engine
  engine_version            = var.db_engine_version
  database_name             = var.stack
  storage_encrypted         = var.storage_encrypted
  lifecycle {
    prevent_destroy = true
  }
}

module "aurora_mysql_rds_cluster_primary" {
  source                             = "../.."
  cluster_type                       = "primary"
  cluster_name                       = "primary"
  providers                          = { aws = aws.primary }
  vpc_id                             = var.vpc_id_primary
  db_engine                          = var.db_engine
  db_engine_version                  = var.db_engine_version
  db_engine_family                   = var.db_engine_family
  db_name                            = var.db_name
  global_cluster_identifier          = aws_rds_global_cluster.default.id
  cluster_parameters                 = var.cluster_parameters
  instance_parameters                = var.instance_parameters
  serverlessv2_scaling_configuration = var.serverlessv2_scaling_configuration
  source_region                      = var.region_primary
  availability_zones                 = var.availability_zones_primary
  db_subnet_group_name               = var.db_subnet_group_name_primary
  security_group_cidr_blocks_allowed = compact(flatten([
    var.security_group_cidr_blocks_allowed
  ]))
  security_groups_ids_allowed     = var.security_groups_ids_allowed_primary
  security_group_ids_add_external = var.security_group_ids_add_external_primary
  master_username                 = "admin"      //also possble use secrets jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["username"]
  master_password                 = "mpasssw0rd" //also possble use secrets jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["password"]
  //kms_key_arn                        = add if you have kms kays for encryption
  storage_encrypted = var.storage_encrypted
  labels = merge(
    { env = var.ENV },
    { component = "db" },
    { prefix = var.prefix },
    { stack = var.stack }
  )
  tags = merge(local.common_tags)
}

# just in case wait 60s to primary cluster full initialization,
# otherwise sometimes Terraform to early start to create second cluster(and aws don't have initialized primary)
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [module.aurora_mysql_rds_cluster_primary]
  create_duration = "60s"
}

module "aurora_mysql_rds_cluster_secondary" {
  source                             = "../.."
  depends_on                         = [time_sleep.wait_60_seconds]
  cluster_type                       = "secondary"
  cluster_name                       = "secondary"
  providers                          = { aws = aws.secondary }
  vpc_id                             = var.vpc_id_secondary
  db_engine                          = var.db_engine
  db_engine_version                  = var.db_engine_version
  db_engine_family                   = var.db_engine_family
  cluster_parameters                 = var.cluster_parameters
  instance_parameters                = var.instance_parameters
  global_cluster_identifier          = aws_rds_global_cluster.default.id
  serverlessv2_scaling_configuration = var.serverlessv2_scaling_configuration
  source_region                      = var.region_secondary
  availability_zones                 = var.availability_zones_secondary
  db_subnet_group_name               = var.db_subnet_group_name_secondary
  security_group_cidr_blocks_allowed = compact(flatten([
    var.security_group_cidr_blocks_allowed
  ]))
  security_groups_ids_allowed     = var.security_groups_ids_allowed_secondary
  security_group_ids_add_external = var.security_group_ids_add_external_secondary
  //kms_key_arn                     = add if you have kms kays for encryption
  storage_encrypted = var.storage_encrypted
  labels = merge(
    { env = var.ENV },
    { component = "db" },
    { prefix = var.prefix },
    { stack = var.stack }
  )
  tags = merge(local.common_tags)
}