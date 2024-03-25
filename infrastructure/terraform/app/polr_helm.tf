locals {
  polr_helm_count    = var.polr_helm_count
  polr_chart_name    = "polr"
  polr_namespce_name = "polr${var.tf_env}"

  polr_dbhost = jsondecode(data.aws_secretsmanager_secret_version.polr_db_secret_name.secret_string)["endpoint"]
  polr_dbport = jsondecode(data.aws_secretsmanager_secret_version.polr_db_secret_name.secret_string)["port"]
  polr_dbuser = jsondecode(data.aws_secretsmanager_secret_version.polr_db_secret_name.secret_string)["username"]
  polr_dbpass = jsondecode(data.aws_secretsmanager_secret_version.polr_db_secret_name.secret_string)["password"]
  polr_dbname = "polr${var.tf_env}db"
}

resource "kubernetes_namespace" "polr" {
  count    = 1
  provider = kubernetes.eks
  metadata {
    annotations = {
      name = local.polr_namespce_name
    }

    labels = {
      name = local.polr_namespce_name
    }

    name = local.polr_namespce_name
  }
}

resource "kubernetes_secret" "polr" {
  count      = local.polr_helm_count
  provider   = kubernetes.eks
  depends_on = [kubernetes_namespace.polr]

  metadata {
    name      = local.polr_chart_name
    namespace = local.polr_namespce_name
  }

  data = {
    mysql-password = local.polr_dbpass
    ADMIN_PASSWORD = local.polr_credentials.password
    polr_dbhost    = jsondecode(data.aws_secretsmanager_secret_version.polr_db_secret_name.secret_string)["endpoint"]
    polr_dbport    = jsondecode(data.aws_secretsmanager_secret_version.polr_db_secret_name.secret_string)["port"]
    polr_dbuser    = jsondecode(data.aws_secretsmanager_secret_version.polr_db_secret_name.secret_string)["username"]
    polr_dbpass    = jsondecode(data.aws_secretsmanager_secret_version.polr_db_secret_name.secret_string)["password"]
    polr_dbname    = local.polr_dbname
  }

  type = "Opaque"
}

resource "kubernetes_job" "polr_db_create" {
  count    = local.polr_helm_count
  provider = kubernetes.eks
  metadata {
    name      = "${local.polr_chart_name}-db-ceate"
    namespace = local.polr_namespce_name
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "polr-job"
          image   = "mysql"
          command = ["/bin/sh", "-c", "echo $(polr_dbhost); mysql -h $(polr_dbhost)  -u $(polr_dbuser) -p$(polr_dbpass) -se 'CREATE DATABASE ${local.polr_dbname};'"]

          env_from {
            secret_ref {
              name = local.polr_chart_name
            }
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}


resource "helm_release" "polr" {
  count = local.polr_helm_count

  depends_on = [kubernetes_secret.polr, kubernetes_job.polr_db_create]

  provider = helm.eks

  //repository = "https://christianhuth.github.io/helm-charts"
  //chart      = "polr"

  chart = "./../../shared/helm-charts/polr"

  name = local.polr_chart_name

  namespace        = local.polr_namespce_name
  create_namespace = true

  set {
    name  = "mysql.enabled"
    value = false
  }

  values = [
    templatefile("${path.module}/helm/helm-chart-polr.yaml",
      {
        image = {
          repository = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.polr_chart_name}"
          pullPolicy = "Always"
          tag        = "latest"
        }

        ingress = {
          enabled   = true
          className = ""
          host      = local.ingress_nginx_dns_name
          path      = "/"
          pathType  = "Prefix" //"ImplementationSpecific" //"Prefix"
        }

        externalDatabase = {
          host           = local.polr_dbhost
          port           = local.polr_dbport
          database       = local.polr_dbname
          username       = local.polr_dbuser
          existingSecret = local.polr_chart_name
          password       = local.polr_dbpass
        }

        admin = {
          username       = local.polr_credentials.username
          existingSecret = local.polr_chart_name
        }

        replicaCount = 4

      }
  )]

}