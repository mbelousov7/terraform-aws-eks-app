################################################################################
# EKS Cluster & IAM roles & Kubernetes resources count managment
################################################################################

eks_cluster_create  = true
cluster_is_deployed = true //define as false during first tf apply, after switch -> true and run apply second time

karpenter_helm_count   = 1
karpenter_iam_count    = 1
karpenter_config_count = 1 //define as 0 during first and second tf apply, after switch -> 1 and run apply one more time

ingress_nginx_helm_count = 1
ingress_nginx_lb_count   = 1 //define as 0 during first and second tf apply, after switch -> 1 and run apply one more time

monitoring_enabled = 1 //define as 0 during first and second tf apply, after switch -> 1 and run apply one more time

db_cluster_count = 1
db_cluster_size  = 1

################################################################################
# EKS Cluster
################################################################################

eks_cluster_version = "1.29"

eks_cluster_manage_aws_auth_configmap = true

eks_cluster_admins_iam_roles = []

eks_cluster_viewers_iam_roles = []

eks_cluster_managed_node_groups_default = {
  name           = "default"
  desired_size   = 1
  min_size       = 1
  max_size       = 2
  instance_types = ["t2.small"]
  capacity_type  = "SPOT"
  //capacity_type  = "ON_DEMAND"

  //workaround to have more pods per small node in personal env
  pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=20/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT


  labels = {
    name = "default"
  }
}

eks_cluster_managed_node_groups = {

}

eks_cluster_security_group_rules_external_subnets = {
}

public_dns_servers = [ # cloudflare
  "1.1.1.1",
  "1.0.0.1",
]

cluster_endpoint_public_access       = true //need to switch to false, and access only via bastion host
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

################################################################################
# Karpenter
################################################################################


karpenter_replicas_count = 2

karpenter_helm_chart_config = {
  controller_image = {
    repository = "public.ecr.aws/karpenter/controller"
    tag        = "0.35.2"
  }

  node_selector = [
    "kubernetes.io/os: linux",
    "name: default",
  ]
}

################################################################################
# EKS ingress-nginx
################################################################################

ingress_nginx_helm_chart_config = {
  image = {
    registry                                 = "registry.k8s.io"
    ingress_nginx_controller_image           = "ingress-nginx/controller"
    ingress_nginx_controller_tag             = "v1.9.6"
    ingress_nginx_kube_webhook_certgen_image = "ingress-nginx/kube-webhook-certgen"
    ingress_nginx_kube_webhook_certgen_tag   = "v20231226-1a7112e06"
    ingress_nginx_default_backend_registry   = "ghcr.io"
    ingress_nginx_default_backend_image      = "tarampampam/error-pages"
    ingress_nginx_default_backend_tag        = "2.26.0"
  }
}

################################################################################
# EKS Monitoring
################################################################################

prometheus_eks_helm_chart_config = {

  configmapReload_prometheus_image = {
    repository = "quay.io/prometheus-operator/prometheus-config-reloader"
    tag        = "v0.72.0"
  }

  server_image = {
    repository = "quay.io/prometheus/prometheus"
    tag        = "v2.51.0"
  }

  kube_state_metrics_image = {
    registry   = "registry.k8s.io"
    repository = "kube-state-metrics/kube-state-metrics"
    tag        = "v2.10.1"
  }

  prometheus_node_exporter_image = {
    registry   = "quay.io"
    repository = "prometheus/node-exporter"
    tag        = "v1.7.0"
  }

  prometheus_pushgateway_image = {
    repository = "quay.io/prometheus/pushgateway"
    tag        = "1.6.2"
  }

}

################################################################################
# ECR repos
################################################################################
ecr_repos = ["polr"]

################################################################################
# RDS Cluster
################################################################################

db_deletion_protection = false

//mysql cluster

db_component      = "mysql"
db_engine         = "aurora-mysql"
db_engine_version = "8.0.mysql_aurora.3.04.0"
db_engine_family  = "aurora-mysql8.0"

db_enabled_cloudwatch_logs_exports = ["error", "slowquery"]

db_cluster_parameters_env = [
  {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "immediate"
  },
  {
    name         = "general_log"
    value        = "1"
    apply_method = "immediate"
  },
]


//postgresql cluster
/*
db_component      = "pgsql"
db_engine         = "postgres"
db_engine_version = "15"
db_engine_family  = "postgres15"

db_enabled_cloudwatch_logs_exports = ["postgresql"]

db_cluster_parameters_env = [
]
*/

db_instance_class = null

//configs to create a Multi-AZ RDS cluster?
//db_storage_type = "io1"
//db_allocated_storage = 100
//db_iops = 1000

serverlessv2_scaling_configuration = {
  min_capacity = 1
  max_capacity = 4
}



