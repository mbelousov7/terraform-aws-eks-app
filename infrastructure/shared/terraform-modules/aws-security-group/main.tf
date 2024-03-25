locals {
  name = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-sg-${var.labels.env}"
}

resource "aws_security_group" "default" {
  name        = local.name
  description = var.security_group_description
  vpc_id      = var.vpc_id
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.name }
  )

  revoke_rules_on_delete = var.revoke_rules_on_delete

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      description = ingress.value.description
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      description = egress.value.description
      cidr_blocks = egress.value.cidr_blocks
    }
  }

}