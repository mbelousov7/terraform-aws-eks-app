data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "polr_db_secret_name" {
  name = var.polr_db_secret_name
}

data "aws_secretsmanager_secret_version" "polr_db_secret_name" {
  secret_id = data.aws_secretsmanager_secret.polr_db_secret_name.id
}

data "aws_lb" "ingress_nginx" {
  tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
  }
}

locals {


  ingress_nginx_dns_name = data.aws_lb.ingress_nginx.dns_name
  polr_url               = "http://${local.ingress_nginx_dns_name}"

  account_id = data.aws_caller_identity.current.account_id

  default_tags = {
    Provisioner = "Terraform"
    "TF:Stack"  = var.tf_stack
    "TF:Zone"   = var.tf_zone
    "TF:Env"    = var.tf_env
  }

  labels = merge(
    { env = var.tf_env },
    { prefix = var.prefix },
    { stack = var.tf_stack },
  )

}