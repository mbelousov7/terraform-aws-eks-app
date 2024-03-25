locals {

  polr_credentials = {
    username = "admin"
    password = random_password.random_string.result
  }

  polr_secrets_name = "${local.polr_chart_name}-secrets-${var.tf_env}"

}

resource "random_password" "random_string" {
  length  = "15"
  lower   = true
  numeric = true
  special = false
  upper   = true

  keepers = {
    pass_version = 1
  }
}

resource "aws_secretsmanager_secret" "polr_secrets" {
  name                    = local.polr_secrets_name
  description             = "polr secrets"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "polr_secrets" {

  secret_id = aws_secretsmanager_secret.polr_secrets.id
  secret_string = jsonencode(merge(
    {
      username = local.polr_credentials.username
      password = local.polr_credentials.password
    }
  ))
}