variable "labels" {
  type = object({
    prefix    = string
    stack     = string
    component = string
    env       = string
  })
  description = "Minimum required map of labels(tags) for creating aws resources"
}


variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}

variable "security_group_description" {
  type        = string
  default     = "Managed by Terraform"
  description = <<-EOT
    The description to assign to the created Security Group.
    Warning: Changing the description causes the security group to be replaced.
    EOT
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
  default     = []
  description = "The map of security group ingress rules"
}


variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
  default     = []
  description = "The map of security group egress rules"
}

variable "revoke_rules_on_delete" {
  type        = bool
  default     = false
  description = <<-EOT
    Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules before deleting
    the security group itself. This is normally not needed.
    EOT
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the Security Group will be created."
}

