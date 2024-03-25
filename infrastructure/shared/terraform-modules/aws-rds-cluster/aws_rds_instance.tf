resource "aws_rds_cluster_instance" "primary" {
  timeouts {
    create = "55m"
    update = "45m"
    delete = "45m"
  }
  count                                 = var.cluster_type == "primary" ? var.cluster_size : 0
  engine                                = var.db_engine
  engine_version                        = var.db_engine_version
  identifier                            = "${local.db_primary_instance}-${count.index + 1}-${var.labels.env}"
  availability_zone                     = local.is_instance_availability_zone ? var.instance_availability_zone : null
  cluster_identifier                    = join("", aws_rds_cluster.primary.*.id)
  db_parameter_group_name               = join("", aws_db_parameter_group.default.*.name)
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  instance_class                        = local.is_serverless ? "db.serverless" : var.db_instance_class
  db_subnet_group_name                  = var.db_subnet_group_name
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period
  tags                                  = merge(local.tags, { "Name" : "${local.db_primary_instance}-${count.index + 1}-${var.labels.env}" })
}

resource "aws_rds_cluster_instance" "secondary" {
  timeouts {
    create = "55m"
    update = "45m"
    delete = "45m"
  }
  count                                 = var.cluster_type == "secondary" ? var.cluster_size : 0
  engine                                = var.db_engine
  engine_version                        = var.db_engine_version
  identifier                            = "${local.db_secondary_instance}-${count.index + 1}-${var.labels.env}"
  availability_zone                     = local.is_instance_availability_zone ? var.instance_availability_zone : null
  cluster_identifier                    = join("", aws_rds_cluster.secondary.*.id)
  db_parameter_group_name               = join("", aws_db_parameter_group.default.*.name)
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  instance_class                        = local.instance_class
  db_subnet_group_name                  = var.db_subnet_group_name
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period
  tags                                  = merge(local.tags, { "Name" : "${local.db_secondary_instance}-${count.index + 1}-${var.labels.env}" })
}