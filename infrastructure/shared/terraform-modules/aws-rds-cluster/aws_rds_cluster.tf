resource "aws_rds_cluster" "primary" {
  timeouts {
    create = "55m"
    update = "45m"
    delete = "45m"
  }
  count                               = var.cluster_type == "primary" ? 1 : 0
  engine                              = var.db_engine
  engine_version                      = var.db_engine_version
  engine_mode                         = local.is_serverless ? null : var.engine_mode
  cluster_identifier                  = local.db_cluster_primary
  source_region                       = var.source_region
  availability_zones                  = var.availability_zones
  storage_encrypted                   = var.storage_encrypted
  storage_type                        = var.storage_type
  iops                                = var.iops
  allocated_storage                   = var.allocated_storage
  kms_key_id                          = var.kms_key_arn
  deletion_protection                 = var.deletion_protection
  global_cluster_identifier           = var.global_cluster_identifier
  database_name                       = var.db_name
  master_username                     = var.master_username
  master_password                     = var.master_password
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles
  backup_retention_period             = var.retention_period
  preferred_backup_window             = var.backup_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  final_snapshot_identifier           = lower(local.db_cluster_primary)
  skip_final_snapshot                 = var.skip_final_snapshot
  apply_immediately                   = var.apply_immediately
  vpc_security_group_ids              = compact(flatten([[module.aws_security_group.id], var.security_group_ids_add_external]))
  db_subnet_group_name                = var.db_subnet_group_name
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.default.name

  allow_major_version_upgrade     = var.allow_major_version_upgrade
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverlessv2_scaling_configuration[*]
    content {
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
    }
  }

  tags = merge(local.tags, { "Name" : local.db_cluster_primary })

}

resource "aws_rds_cluster" "secondary" {
  timeouts {
    create = "55m"
    update = "45m"
    delete = "45m"
  }
  count                     = var.cluster_type == "secondary" ? 1 : 0
  engine                    = var.db_engine
  engine_version            = var.db_engine_version
  engine_mode               = local.is_serverless ? null : var.engine_mode
  cluster_identifier        = local.db_cluster_secondary
  global_cluster_identifier = var.global_cluster_identifier
  source_region             = var.source_region
  availability_zones        = var.availability_zones
  storage_encrypted         = var.storage_encrypted
  storage_type              = var.storage_type
  iops                      = var.iops
  // no need to specify db name and creds for secondary cluster, here just for example
  //database_name                       = var.database_name
  //master_username                     = var.master_username
  //master_password                     = var.master_password
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles
  backup_retention_period             = var.retention_period
  preferred_backup_window             = var.backup_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  final_snapshot_identifier           = lower(local.db_cluster_secondary)
  skip_final_snapshot                 = var.skip_final_snapshot
  apply_immediately                   = var.apply_immediately

  kms_key_id                      = var.kms_key_arn
  vpc_security_group_ids          = compact(flatten([[module.aws_security_group.id], var.security_group_ids_add_external]))
  db_subnet_group_name            = var.db_subnet_group_name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
  deletion_protection             = var.deletion_protection
  allow_major_version_upgrade     = var.allow_major_version_upgrade
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverlessv2_scaling_configuration[*]
    content {
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
    }
  }

  lifecycle {
    ignore_changes = [
      replication_source_identifier, # will be set/managed by Global Cluster
    ]
  }

  tags = merge(local.tags, { "Name" : local.db_cluster_secondary })
}

resource "aws_rds_cluster_endpoint" "primary_reader" {
  count                       = var.cluster_type == "primary" && var.cluster_custom_endpoint == true ? 1 : 0
  cluster_identifier          = join("", aws_rds_cluster.primary.*.id)
  cluster_endpoint_identifier = "${local.db_cluster_primary}-reader"
  custom_endpoint_type        = "READER"
}

resource "aws_rds_cluster_endpoint" "secondary_reader" {
  count                       = var.cluster_type == "secondary" && var.cluster_custom_endpoint == true ? 1 : 0
  cluster_identifier          = join("", aws_rds_cluster.secondary.*.id)
  cluster_endpoint_identifier = "${local.db_cluster_secondary}-reader"
  custom_endpoint_type        = "READER"
}