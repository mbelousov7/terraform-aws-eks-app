/*
karpenter components:
- An IAM role ${karpenter_iam_role_name_pod} for service accounts (IRSA) with a narrowly scoped IAM policy for the Karpenter controller to utilize
- An IAM role ${karpenter_iam_role_name_node} and instance profile for the nodes created by Karpenter to utilize
  - Note: This IAM role ARN will need to be added to the `aws-auth` configmap for nodes to join the cluster successfully
- An SQS queue and Eventbridge event rules for Karpenter to utilize for spot termination handling, capacity rebalancing, etc.
- karpenter helm-chart
- kurpenter custom  k8s manifests 
  - EC2NodeClass: node aws config templates to create
  - NodePool: nodes k8s checks and configs to create
*/

locals {

  karpenter_iam_count = var.karpenter_iam_count

  karpenter_config_count = var.cluster_is_deployed && var.karpenter_config_count == 1 ? 1 : 0
  karpenter_helm_count   = var.cluster_is_deployed && var.karpenter_helm_count == 1 ? 1 : 0
  karpenter_eks_count    = var.cluster_is_deployed && var.karpenter_iam_count == 1 ? 1 : 0

  karpenter_chart_name = "karpenter"
  karpenter_namespace  = "karpenter"

  karpenter_iam_role_name_pod  = "${local.eks_cluster_name}-karpenter-pod"
  karpenter_iam_role_name_node = "${local.eks_cluster_name}-karpenter-node"
  karpenter_iam_role_path      = "/${var.tf_stack}/"
  karpenter_node_class         = "default"
  karpenter_node_pull          = "default"

}

module "karpenter_eks" { //recreate module in case of karpenter_iam_role_name_pod or karpenter_iam_role_name_node changing
  count  = local.karpenter_eks_count
  source = "./../../shared/terraform-modules/terraform-aws-eks/modules/karpenter"

  cluster_name = local.eks_cluster_name

  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  irsa_use_name_prefix = false
  irsa_path            = local.karpenter_iam_role_path
  irsa_name            = local.karpenter_iam_role_name_pod
  irsa_policy_name     = local.karpenter_iam_role_name_pod

  iam_role_use_name_prefix = false
  iam_role_name            = local.karpenter_iam_role_name_node
  iam_role_path            = local.karpenter_iam_role_path

  irsa_namespace_service_accounts = ["${local.karpenter_namespace}:${local.karpenter_iam_role_name_pod}"]

  enable_karpenter_instance_profile_creation = true

  queue_name = local.eks_cluster_name

  # Attach additional IAM policies to the Karpenter node IAM role
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

}

resource "helm_release" "karpenter" {
  count      = local.karpenter_helm_count
  chart      = "./../../shared/helm-charts/karpenter-v0.35.2"
  provider   = helm.eks
  depends_on = [module.karpenter_eks]

  name = local.karpenter_chart_name

  namespace        = local.karpenter_namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/helm/helm-chart-karpenter.yaml",
      {

        serviceAccount = {
          annotations = [
            "eks.amazonaws.com/role-arn: ${join("", module.karpenter_eks.*.irsa_arn)}",
          ]
          name = join("", module.karpenter_eks.*.irsa_name)
        }

        settings = {
          clusterName     = local.eks_cluster_name
          clusterEndpoint = join("", data.aws_eks_cluster.eks.*.endpoint)
        }

        interruptionQueue = join("", module.karpenter_eks.*.queue_name)

        controller = {
          image = var.karpenter_helm_chart_config.controller_image
        }

        replicas      = var.karpenter_replicas_count
        node_selector = var.karpenter_helm_chart_config.node_selector

    })
  ]

}