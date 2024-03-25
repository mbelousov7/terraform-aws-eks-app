################################################################################
# EKS Drivers
################################################################################

locals {
  ebs_csi_driver_iam_count       = var.eks_cluster_count == 1 && var.ebs_csi_driver_iam_count == 1 ? 1 : 0
  ebs_csi_driver_iam_role_name   = "${var.tf_stack}-${var.tf_zone}-ebs-csi-driver-${local.region_short}"
  ebs_csi_driver_iam_role_path   = "/${var.tf_stack}/"
  ebs_csi_driver_iam_policy_name = "${var.tf_stack}-${var.tf_zone}-ebs-csi-driver-${local.region_short}"

}

module "ebs_csi_driver_iam_role" {
  count  = local.ebs_csi_driver_iam_count
  source = "./../../shared/terraform-modules/aws-iam-eks-role"

  depends_on = [module.eks]

  role_name = local.ebs_csi_driver_iam_role_name
  role_path = local.ebs_csi_driver_iam_role_path
  role_policy_arns = {
    EbsCsiDriver = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  cluster_service_accounts = {
    "${local.eks_cluster_name}" = ["kube-system:ebs-csi-controller-sa"]
  }

}




