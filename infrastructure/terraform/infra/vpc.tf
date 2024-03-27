data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "all_priv" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*1a", "*1b", "*1c"]
  }
  tags = {
    Type = "private"
  }
}

data "aws_subnets" "all_pub" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*1a", "*1b", "*1c"]
  }
  tags = {
    Type = "public"
  }
}

data "aws_subnet" "all_priv_subnet" {
  for_each = toset(data.aws_subnets.all_priv.ids)
  id       = each.value
}

data "aws_subnet" "all_pub_subnet" {
  for_each = toset(data.aws_subnets.all_pub.ids)
  id       = each.value
}

locals {

  priv_subnets     = [for s in data.aws_subnets.all_priv.ids : s]
  priv_cidr_blocks = [for subnet_id, subnet_data in data.aws_subnet.all_priv_subnet : subnet_data.cidr_block]

  pub_subnets     = [for s in data.aws_subnets.all_pub.ids : s]
  pub_cidr_blocks = [for subnet_id, subnet_data in data.aws_subnet.all_pub_subnet : subnet_data.cidr_block]

  priv_subnets_1a = [for s in data.aws_subnet.all_priv_subnet : s.id if s.availability_zone == "${var.region}a"]
  priv_subnets_1b = [for s in data.aws_subnet.all_priv_subnet : s.id if s.availability_zone == "${var.region}b"]
  priv_subnets_1c = [for s in data.aws_subnet.all_priv_subnet : s.id if s.availability_zone == "${var.region}c"]

  aws_vpc_endpoints = {
    vpc_autoscaling    = "com.amazonaws.${var.region}.autoscaling"
    vpc_ecr_dkr        = "com.amazonaws.${var.region}.ecr.dkr"
    vpc_ecr_api        = "com.amazonaws.${var.region}.ecr.api"
    vpc_logs           = "com.amazonaws.${var.region}.logs"
    vpc_secretsmanager = "com.amazonaws.${var.region}.secretsmanager"
    vpc_ssm            = "com.amazonaws.${var.region}.ssm"
    vpc_eks            = "com.amazonaws.${var.region}.eks"
    sqs                = "com.amazonaws.${var.region}.sqs"
  }

}

/* don't create aws_vpc_endpoint in demo env
data "aws_vpc_endpoint" "vpc_endpoint" {
  for_each     = local.aws_vpc_endpoints
  service_name = each.value
  vpc_id       = data.aws_vpc.main.id
}

resource "aws_security_group_rule" "sg_vpc_endpoint_cluster_control_plane" {
  for_each                 = local.aws_vpc_endpoints
  security_group_id        = tolist(data.aws_vpc_endpoint.vpc_endpoint[each.key].security_group_ids)[0]
  type                     = "ingress"
  protocol                 = "TCP"
  from_port                = 443
  to_port                  = 443
  description              = "Allow access from ${var.tf_stack}-${var.tf_zone} EKS cluster control-plane-to-data-plane"
  source_security_group_id = module.eks.cluster_primary_security_group_id
}

resource "aws_security_group_rule" "sg_vpc_endpoint_cluster_nodes" {
  for_each                 = local.aws_vpc_endpoints
  security_group_id        = tolist(data.aws_vpc_endpoint.vpc_endpoint[each.key].security_group_ids)[0]
  type                     = "ingress"
  protocol                 = "TCP"
  from_port                = 443
  to_port                  = 443
  description              = "Allow access from ${var.tf_stack}-${var.tf_zone} EKS cluster nodes"
  source_security_group_id = module.eks.node_security_group_id
}
*/
