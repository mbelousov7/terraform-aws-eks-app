locals {

  vpc_name = var.vpc_name
  igw_name = var.igw_name
  dsg_name = var.dsg_name

}

resource "aws_vpc" "default" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    var.tags,
    { Name = local.vpc_name }
  )
}

# If `aws_default_security_group` is not defined, it will be created implicitly with access `0.0.0.0/0`
resource "aws_default_security_group" "default" {
  count  = var.default_security_group_deny_all ? 1 : 0
  vpc_id = aws_vpc.default.id
  tags = merge(
    var.tags,
    { Name = local.dsg_name }
  )
}

resource "aws_internet_gateway" "default" {
  count  = var.igw_enable ? 1 : 0
  vpc_id = aws_vpc.default.id
  tags = merge(
    var.tags,
    { Name = local.igw_name }
  )
}