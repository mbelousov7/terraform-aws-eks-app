locals {
  vpc_count = 1

  vpc_name = "${var.tf_stack}-${var.tf_zone}-${var.region}"
  igw_name = "${var.tf_stack}-${var.tf_zone}-${var.region}-igw"
  dsg_name = "${var.tf_stack}-${var.tf_zone}-${var.region}-dsg"

}

module "vpc" {
  source = "./../../shared/terraform-modules/aws-vpc"
  count  = local.vpc_count

  vpc_name   = local.vpc_name
  igw_name   = local.igw_name
  dsg_name   = local.dsg_name
  igw_enable = var.vpc_config.igw_enable
  cidr_block = var.vpc_config.vpc_cidr_block
}

module "subnet_private" {
  source            = "./../../shared/terraform-modules/aws-subnet"
  for_each          = var.subnets_config_private
  subnet_name       = "${local.vpc_name}-priv-${each.key}"
  type              = "private"
  ngw_enable        = true
  ngw_id            = module.subnet_public["${each.key}"].ngw_id
  availability_zone = each.key
  vpc_id            = join("", module.vpc.*.vpc_id)
  cidr_block        = each.value.cidr_blocks[0]

  depends_on = [module.vpc, module.subnet_public]
}

module "subnet_public" {
  source                  = "./../../shared/terraform-modules/aws-subnet"
  for_each                = var.subnets_config_public
  subnet_name             = "${local.vpc_name}-pub-${each.key}"
  map_public_ip_on_launch = true
  type                    = "public"
  ngw_enable              = true
  availability_zone       = each.key
  vpc_id                  = join("", module.vpc.*.vpc_id)
  igw_id                  = join("", module.vpc.*.igw_id)
  cidr_block              = each.value.cidr_blocks[0]

  depends_on = [module.vpc]
}








