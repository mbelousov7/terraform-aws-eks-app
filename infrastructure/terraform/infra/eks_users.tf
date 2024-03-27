################################################################################
# EKS users
################################################################################

locals {
  kubernetes_roles_count = var.cluster_is_deployed ? 1 : 0
}

data "aws_iam_role" "eks_aws_admins_iam_roles" {
  for_each = { for role_name in var.eks_cluster_admins_iam_roles : role_name => role_name }
  name     = each.value
}

data "aws_iam_role" "eks_aws_viewers_iam_roles" {
  for_each = { for role_name in var.eks_cluster_viewers_iam_roles : role_name => role_name }
  name     = each.value
}


// use iam role data in resources which required this role must be exist already

locals {

  karpenter_iam_role_name_node_real = join("", module.karpenter_eks.*.role_name) == "" ? [] : [join("", module.karpenter_eks.*.role_name)]


  eks_aws_admins_iam_roles_arn  = concat([for role_name, role_data in data.aws_iam_role.eks_aws_admins_iam_roles : role_data.arn], )
  eks_aws_viewers_iam_roles_arn = concat([for role_name, role_data in data.aws_iam_role.eks_aws_viewers_iam_roles : role_data.arn], )

  eks_cluster_admins_iam_roles = concat(
    var.eks_cluster_admins_iam_roles,
    local.karpenter_iam_role_name_node_real
  )

  eks_cluster_viewers_iam_roles = concat(var.eks_cluster_viewers_iam_roles)

  eks_aws_admins_iam_roles_arn_no_path = [
    for role in local.eks_cluster_admins_iam_roles : {
      rolearn  = "arn:aws:iam::${local.account_id}:role/${role}"
      username = role
      groups = [
        "system:masters"
      ]
    }
  ]

  eks_aws_viewers_iam_roles_arn_no_path = [
    for role in local.eks_cluster_viewers_iam_roles : {
      rolearn  = "arn:aws:iam::${local.account_id}:role/${role}"
      username = role
      groups = [
        "viewer",
        "low_integrity"
      ]
    }
  ]

  eks_aws_auth_roles = concat(
    local.eks_aws_admins_iam_roles_arn_no_path,
    local.eks_aws_viewers_iam_roles_arn_no_path,
  )
}


resource "kubernetes_cluster_role" "viewer" {
  count = local.kubernetes_roles_count
  metadata {
    name = "viewer"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "viewer" {
  count = local.kubernetes_roles_count
  metadata {
    name = "viewer"
  }

  subject {
    kind      = "Group"
    name      = "viewer"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "viewer"
  }

}


