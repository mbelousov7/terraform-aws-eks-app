locals {
  db_cluster_name      = "app-${local.region_short}"
  db_component_name    = var.db_component
  db_name              = "mydatabase"
  db_subnet_group_name = "${var.tf_stack}-${var.tf_zone}-db-${local.region_short}"

  db_labels = merge(
    { env = var.tf_zone },
    { prefix = "db" },
    { stack = var.tf_stack }
  )
}


resource "aws_db_subnet_group" "primary" {
  count       = 1
  name        = local.db_subnet_group_name
  description = "subnet_group for Aurora cluster"
  subnet_ids  = local.priv_subnets
}

resource "aws_cloudwatch_log_group" "primary" {
  for_each = toset(var.db_enabled_cloudwatch_logs_exports)
  //name should be like /aws/rds/cluster/${cluster_identifier}
  name              = "/aws/rds/cluster/${local.db_labels.prefix}-${local.db_labels.stack}-${local.db_component_name}-${local.db_cluster_name}-${local.db_labels.env}/${each.key}"
  retention_in_days = 30
}

/*resource "aws_sns_topic" "primary" {
  name = "db-${var.tf_stack}-${var.tf_zone}-cl"
}*/

module "aurora_mysql_rds_cluster_primary" {
  source = "./../../shared/terraform-modules/aws-rds-cluster"
  depends_on = [
    aws_cloudwatch_log_group.primary
  ]
  count                              = var.db_cluster_count
  cluster_name                       = local.db_cluster_name
  cluster_type                       = "primary"
  vpc_id                             = data.aws_vpc.main.id
  db_engine                          = var.db_engine
  db_engine_version                  = var.db_engine_version
  db_engine_family                   = var.db_engine_family
  auto_minor_version_upgrade         = true
  db_name                            = local.db_name
  master_username                    = local.db_credentials.username
  master_password                    = local.db_credentials.password
  global_cluster_identifier          = null
  cluster_size                       = var.db_cluster_size
  cluster_parameters                 = concat(var.db_cluster_parameters, var.db_cluster_parameters_env)
  instance_parameters                = var.db_instance_parameters
  serverlessv2_scaling_configuration = var.serverlessv2_scaling_configuration
  source_region                      = var.region
  availability_zones                 = var.availability_zones
  storage_encrypted                  = var.db_storage_encrypted
  db_instance_class                  = var.db_instance_class
  storage_type                       = var.db_storage_type
  iops                               = var.db_iops
  allocated_storage                  = var.db_allocated_storage
  kms_key_arn                        = null
  deletion_protection                = var.db_deletion_protection
  db_subnet_group_name               = join("", aws_db_subnet_group.primary.*.id)
  security_group_cidr_blocks_allowed = local.priv_cidr_blocks
  security_groups_ids_allowed        = []
  security_group_ids_add_external    = []
  labels                             = merge(local.db_labels, { component = local.db_component_name }, )
  enabled_cloudwatch_logs_exports    = var.db_enabled_cloudwatch_logs_exports

  alarm_enable = false
  //alarm_topic_arn = aws_sns_topic.primary.arn

}