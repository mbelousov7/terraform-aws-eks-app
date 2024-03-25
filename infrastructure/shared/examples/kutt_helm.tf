locals {
  kutt_helm_count = var.kutt_helm_count
  kutt_chart_name = "kutt"
}

/*resource "helm_release" "kutt" {

  chart    = "./../../shared/helm-charts/kutt-4.0.2"
  count    = local.kutt_helm_count
  provider = helm.eks
  name     = local.kutt_chart_name

  namespace        = local.kutt_chart_name
  create_namespace = true

}
*/

resource "helm_release" "kutt" {
  count    = local.kutt_helm_count
  chart    = "./../../shared/helm-charts/kutt-4.0.2"
  provider = helm.eks

  name = local.kutt_chart_name

  namespace        = local.kutt_chart_name
  create_namespace = true

  values = [
    templatefile("${path.module}/helm/helm-chart-kutt.yaml",
      {

        ingress = {
          enabled   = true
          className = ""
          host      = local.ingress_nginx_dns_name
          path      = "/"
        }

        image = {
          repository = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.kutt_chart_name}"
          pullPolicy = "Always"
          tag        = "latest"
        }

        kutt = {
          admin = "mbelousov7@gmail.com"
        }

        mail = {
          from     = "mbelousov7@gmail.com"
          host     = "smtp.testtest.com"
          password = "test"
          port     = "25"
          username = "test"
        }

        autoscaling = {
          enabled = false
        }

        domain = {
          customDomainUseHttps = false
          defaultDomain        = "${local.ingress_nginx_dns_name}"
          useFirstIngressHost  = true
        }

        replicaCount = 1

        postgresql = {
          enabled = true
        }

        externalPostgresql = {
          auth = {
            database        = "kutt"
            existingSecret  = ""
            password        = "kutt"
            username        = "kutt"
            userPasswordKey = ""
          }
          hostname = ""
          port     = 5432
        }
        redis = {
          enabled      = true
          architecture = "replication" //"replication" or "standalone"
        }

        node_selector = [
          "kubernetes.io/os: linux",
          "name: default",
        ]

    })
  ]

}