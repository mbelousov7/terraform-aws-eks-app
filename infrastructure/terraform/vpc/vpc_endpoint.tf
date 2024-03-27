locals {

  vpc_id       = module.vpc[0].vpc_id
  priv_subnets = [for s in module.subnet_private : s.subnet_id]


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



resource "aws_security_group" "private" {
  for_each    = local.aws_vpc_endpoints
  name        = each.key
  description = "vpc endpoint ${each.key} sg"
  vpc_id      = local.vpc_id

  tags = {
    Name = each.key
  }
}

resource "aws_vpc_endpoint" "private" {
  for_each = local.aws_vpc_endpoints

  vpc_id             = local.vpc_id
  subnet_ids         = local.priv_subnets
  security_group_ids = [aws_security_group.private[each.key].id]
  vpc_endpoint_type  = "Interface"
  service_name       = each.value

  tags = {
    Name = each.key
  }

}


