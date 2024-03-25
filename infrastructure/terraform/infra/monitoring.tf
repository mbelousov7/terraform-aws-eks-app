
locals {

  prometheus_eks_chart_name    = "prometheus-eks"
  prometheus_eks_name          = "prometheus-eks-${local.eks_cluster_name}"
  prometheus_eks_sa_name       = local.prometheus_eks_name
  prometheus_eks_iam_role_name = local.prometheus_eks_name
  prometheus_eks_namespace     = "monitoring"
  prometheus_eks_chart_count   = var.bootstrap_eks_count == 1 && var.monitoring_enabled == 1 ? 1 : 0

}

resource "helm_release" "prometheus_eks" {
  count      = local.prometheus_eks_chart_count
  provider   = helm.eks
  chart      = "./../../shared/helm-charts/prometheus-25.11.0"
  depends_on = [module.eks]

  name = local.prometheus_eks_chart_name

  namespace        = local.prometheus_eks_namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/helm/helm-chart-prometheus-eks.yaml",
      {
        aws_eks_cluster_name = local.eks_cluster_name

        serviceAccounts = {
          server = {
            name = local.prometheus_eks_name
            annotations = [
              "chart: ${local.prometheus_eks_chart_name}"
            ]
          }


        }

        configmapReload = {
          prometheus = {
            image = var.prometheus_eks_helm_chart_config.configmapReload_prometheus_image
          }
        }

        server = {
          image = var.prometheus_eks_helm_chart_config.server_image

          extraArgs = [
            "log.level: info",
            "web.external-url: http://${join("", data.aws_lb.ingress_nginx.*.dns_name)}/prometheus",
            "web.route-prefix: /"
          ]

          ingress = {
            ingressClassName = local.ingress_nginx_class
            enabled          = true
            hosts            = ["${join("", data.aws_lb.ingress_nginx.*.dns_name)}"]
            path             = "/prometheus(/|$)(.*)"
          }

        }

        persistentVolume = {
          enabled = false
          size    = "10Gi"
        }

        job_kubernetes_pods = {
          source_labels_keep = "__meta_kubernetes_pod_annotation_prometheus_io_scrape"
        }

        job_kubernetes_service_endpoints = {
          source_labels_keep = "__meta_kubernetes_service_annotation_prometheus_io_scrape"
        }

        probes = {

        }

        kube_state_metrics = {
          enabled = "true"
          #kube-state-metrics chart variables
          image = var.prometheus_eks_helm_chart_config.kube_state_metrics_image
        }

        prometheus_node_exporter = {
          enabled = "true"
          #prometheus-node-exporter chart variables
          image = var.prometheus_eks_helm_chart_config.prometheus_node_exporter_image
        }

        prometheus_pushgateway = {
          enabled = "false"
          #prometheus-node-exporter chart variables
          image = var.prometheus_eks_helm_chart_config.prometheus_pushgateway_image
        }

        node_selector = [
          "kubernetes.io/os: linux",
          "name: default",
        ]

    })

  ]

}

