resource "aws_rds_cluster_parameter_group" "default" {
  name   = local.db_cluster_param_group
  family = var.db_engine_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, { "Name" : local.db_cluster_param_group })
}

resource "aws_db_parameter_group" "default" {
  name   = local.db_param_group
  family = var.db_engine_family

  dynamic "parameter" {
    for_each = var.instance_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, { "Name" : local.db_cluster_param_group })
}