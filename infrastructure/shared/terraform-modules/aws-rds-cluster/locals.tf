locals {

  is_serverless                        = var.serverlessv2_scaling_configuration != null && (var.db_instance_class == null || var.db_instance_class == "db.serverless")
  instance_class                       = local.is_serverless ? "db.serverless" : var.db_instance_class
  is_instance_availability_zone        = var.instance_availability_zone != null
  is_instance_availability_zone_reader = var.instance_availability_zone_reader != null

  tags = merge(
    var.labels,
    var.tags,
  )

  //cluster_primary_n   = var.global_cluster_identifier == null ? "primary-" : var.global_cluster_identifier
  //cluster_secondary_n = var.global_cluster_identifier == null ? "secondary-" : var.global_cluster_identifier

  cluster_name           = var.cluster_name == null ? var.cluster_type : var.cluster_name
  cluster_name_primary   = var.cluster_name == null ? "primary" : var.cluster_name
  cluster_name_secondary = var.cluster_name == null ? "secondary" : var.cluster_name

  db_security_group = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-security-group-${local.cluster_name}-${var.labels.env}"

  //db_cluster            = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-global-${var.labels.env}"
  db_cluster_primary    = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-${local.cluster_name_primary}-${var.labels.env}"
  db_cluster_secondary  = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-${local.cluster_name_secondary}-${var.labels.env}"
  db_primary_instance   = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-${local.cluster_name_primary}-instance"
  db_secondary_instance = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-${local.cluster_name_secondary}-instance"

  db_param_group         = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-param-group-${var.cluster_name}-${var.labels.env}"
  db_cluster_param_group = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-cluster-param-group-${var.cluster_name}-${var.labels.env}"
}