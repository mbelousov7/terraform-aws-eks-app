module "aws_security_group" {
  source                  = "./aws_security_group"
  name                    = local.db_security_group
  vpc_id                  = var.vpc_id
  cidr_blocks_allowed     = var.security_group_cidr_blocks_allowed
  security_groups_allowed = var.security_groups_ids_allowed
  db_port                 = var.db_port
  base_tags               = local.tags
}
