resource "aws_security_group" "default" {
  name        = var.name
  description = "Allow inbound traffic from Security Groups and CIDRs"
  vpc_id      = var.vpc_id
  tags        = merge(var.base_tags, { "Name" : var.name })
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = length(var.security_groups_allowed)
  description              = "Allow inbound traffic from existing security groups"
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = var.security_groups_allowed[count.index]
  security_group_id        = aws_security_group.default.id
}

resource "aws_security_group_rule" "traffic_inside_security_group" {
  description       = "Allow traffic between members of the database security group"
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = length(var.cidr_blocks_allowed) > 0 ? 1 : 0
  description       = "Allow inbound traffic from existing CIDR blocks"
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks_allowed
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "egress" {
  description       = "Allow outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}