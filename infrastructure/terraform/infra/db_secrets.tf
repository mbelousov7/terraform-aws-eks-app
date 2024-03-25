locals {

  db_credentials = {
    username = var.db_username
    password = random_password.random_string.result
  }

  db_secrets_name = "${local.db_labels.prefix}-${local.db_labels.stack}-secrets-${local.db_labels.env}"

}

resource "random_password" "random_string" {
  length  = "15"
  lower   = true
  numeric = true
  special = false
  upper   = true

  keepers = {
    pass_version = var.db_pass_version
  }
}

resource "aws_secretsmanager_secret" "db_secrets" {
  name                    = local.db_secrets_name
  description             = "RDS cluster secrets and outputs"
  recovery_window_in_days = 0
  tags                    = merge(local.db_labels, { component = local.db_component_name }, )
}

resource "aws_secretsmanager_secret_version" "db_secrets" {

  secret_id = aws_secretsmanager_secret.db_secrets.id
  secret_string = jsonencode(merge(
    {
      pass_version    = var.db_pass_version
      username        = local.db_credentials.username
      password        = local.db_credentials.password
      dbname          = local.db_name
      endpoint        = join("", module.aurora_mysql_rds_cluster_primary.*.endpoint)
      endpoint_reader = join("", module.aurora_mysql_rds_cluster_primary.*.endpoint_reader)
      port            = join("", module.aurora_mysql_rds_cluster_primary.*.port)
    }
  ))
}
