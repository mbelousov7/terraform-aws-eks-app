locals {

  eks_create = var.eks_cluster_count == 1 ? true : false

  eks_cluster_manage_aws_auth_configmap = var.bootstrap_eks_count == 1 ? true : false

  eks_tags = merge(
    { "karpenter.sh/discovery" = local.eks_cluster_name },
  )

  eks_cluster_name       = "${var.tf_stack}-${var.tf_zone}-cl-${local.region_short}"
  eks_cluster_subnet_ids = concat(local.priv_subnets)

  cluster_additional_security_group_ids = []

  eks_cluster_security_group_rules = merge(
    var.eks_cluster_security_group_rules_external_subnets,
  )

  eks_cluster_managed_node_groups = merge(
    var.eks_cluster_managed_node_groups,
    local.eks_cluster_managed_node_groups_default_multy_az,
  )

  eks_cluster_managed_node_groups_default_multy_az = {
    for subnet in data.aws_subnet.all_priv_subnet : "default_az_${trimprefix(subnet.availability_zone, "eu-west-")}" => {
      name                    = "${var.tf_zone}-${local.region_short}-${var.eks_cluster_managed_node_groups_default.name}"
      desired_size            = var.eks_cluster_managed_node_groups_default.desired_size
      min_size                = var.eks_cluster_managed_node_groups_default.min_size
      max_size                = var.eks_cluster_managed_node_groups_default.max_size
      instance_types          = var.eks_cluster_managed_node_groups_default.instance_types
      capacity_type           = var.eks_cluster_managed_node_groups_default.capacity_type
      pre_bootstrap_user_data = var.eks_cluster_managed_node_groups_default.pre_bootstrap_user_data

      labels = merge(
        { az = trimprefix(subnet.availability_zone, "eu-west-") },
        var.eks_cluster_managed_node_groups_default.labels
      )

      subnet_ids = [subnet.id]
    }
  }
}


module "eks" {

  //count = local.eks_cluster_count

  create = local.eks_create

  source = "./../../shared/terraform-modules/terraform-aws-eks"

  cluster_name    = local.eks_cluster_name
  cluster_version = var.eks_cluster_version

  cluster_endpoint_public_access       = var.cluster_endpoint_public_access       //true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs //["0.0.0.0/0"] //todo use your ip|subnet

  vpc_id     = data.aws_vpc.main.id
  subnet_ids = local.eks_cluster_subnet_ids

  cluster_security_group_additional_rules = local.eks_cluster_security_group_rules
  cluster_additional_security_group_ids   = local.cluster_additional_security_group_ids

  kms_key_viewers = []
  kms_key_owners  = []

  create_aws_auth_configmap = false
  manage_aws_auth_configmap = local.eks_cluster_manage_aws_auth_configmap

  aws_auth_roles = local.eks_aws_auth_roles

  cluster_service_ipv4_cidr = var.eks_cluster_service_ipv4_cidr

  eks_managed_node_group_defaults = {
    instance_types             = ["t2.micro"]
    iam_role_attach_cni_policy = true
    use_custom_launch_template = true //must be true for IMDSv2 configuration
    disk_size                  = 50
    //bootstrap_extra_args 
    //pre_bootstrap_user_data    = 
    //workaround to have more pods per small node in personal env
    /*pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=30/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
    */


    block_device_mappings = {
      disk1 = {
        device_name = "/dev/xvda"
        ebs = {
          delete_on_termination = true
          encrypted             = true
          volume_size           = 50
          volume_type           = "gp3"
          kms_key_id            = null //use default aws/ebs kms key
        }
      }
    }
  }

  eks_managed_node_groups = local.eks_cluster_managed_node_groups

  cluster_addons = {

    coredns = {
      configuration_values = templatefile("${path.module}/files/coredns_config.yml.tpl", {
        public_dns_servers = join(" ", var.public_dns_servers)
      })
    }

    vpc-cni = {}

    aws-ebs-csi-driver = {
      service_account_role_arn = "arn:aws:iam::${local.account_id}:role${local.ebs_csi_driver_iam_role_path}${local.ebs_csi_driver_iam_role_name}"
    }

    kube-proxy = {}

  }

  tags = local.eks_tags
}





