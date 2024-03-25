resource "kubernetes_manifest" "karpenter_node_class_default" {
  count    = local.karpenter_config_count
  provider = kubernetes.eks
  manifest = {
    "apiVersion" = "karpenter.k8s.aws/v1beta1"
    "kind"       = "EC2NodeClass"
    "metadata" = {
      "name" = "${local.karpenter_node_class}"
    }
    "spec" = {
      "amiFamily" = "AL2"
      "role"      = "${join("", module.karpenter_eks.*.role_name)}"
      "securityGroupSelectorTerms" = [
        {
          "id" = "${module.eks.node_security_group_id}"
        },
      ]
      "subnetSelectorTerms" = [
        {
          "tags" = {
            "Name" = "${var.vpc_name}-priv*"
            "Type" = "private"
          }
        },
      ]
      "tags" = {
        "Name"                   = "${local.eks_cluster_name}-karpenter"
        "karpenter.sh/discovery" = "${local.eks_cluster_name}"
      }
    }
  }

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubernetes_manifest" "karpenter_node_pool_default" {
  count    = local.karpenter_config_count
  provider = kubernetes.eks
  manifest = {
    "apiVersion" = "karpenter.sh/v1beta1"
    "kind"       = "NodePool"
    "metadata" = {
      "name" = "${local.karpenter_node_pull}"
    }
    "spec" = {
      "disruption" = {
        "consolidationPolicy" = "WhenUnderutilized"
        "expireAfter"         = "2h"
      }
      "limits" = {
        "cpu"    = "20"
        "memory" = "50Gi"
      }
      "template" = {
        "spec" = {
          "nodeClassRef" = {
            "name" = "${local.karpenter_node_class}"
          }
          "requirements" = [
            {
              "key"      = "name" //node group name
              "operator" = "In"
              "values" = [
                "default",
                "test",
              ]
            },
            {
              "key"      = "node.kubernetes.io/instance-type"
              "operator" = "In"
              "values" = [
                "t2.small",
              ]
            },
            {
              "key"      = "kubernetes.io/os"
              "operator" = "In"
              "values" = [
                "linux",
              ]
            },
            {
              "key"      = "kubernetes.io/arch"
              "operator" = "In"
              "values" = [
                "amd64",
              ]
            },
            {
              "key"      = "karpenter.sh/capacity-type"
              "operator" = "In"
              "values" = [
                "on-demand", "spot"
              ]
            },
          ]
        }
      }
    }
  }

  depends_on = [
    helm_release.karpenter
  ]

}
