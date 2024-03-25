locals {
  aws_vpc_endpoints = {
    vpc_autoscaling    = "com.amazonaws.${var.region}.autoscaling"
    vpc_ecr_dkr        = "com.amazonaws.${var.region}.ecr.dkr"
    vpc_ecr_api        = "com.amazonaws.${var.region}.ecr.api"
    vpc_logs           = "com.amazonaws.${var.region}.logs"
    vpc_secretsmanager = "com.amazonaws.${var.region}.secretsmanager"
    vpc_ssm            = "ssm.${var.region}.amazonaws.com"
    vpc_ec2messages    = "ec2messages.${var.region}.amazonaws.com"
    vpc_ssmmessages    = "ssmmessages.${var.region}.amazonaws.com"

  }
}

//ToDo Create endpoint for all subnets