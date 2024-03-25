# Get object aws_vpc by vpc_id
data "aws_vpc" "default" {
  id = var.vpc_id
}

locals {
  subnet_name = var.subnet_name
  ngw_name    = "${local.subnet_name}-ngw"
}