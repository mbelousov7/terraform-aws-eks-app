#################################################  <ENV>.tfvars  #################################################
# in the examples for modules, variables are defined and set in the same file as the module definition.
# This is done to better understand the meaning of the variables.
# In a real environment, you should define variables in a variables.tf, the values of variables depending on the environment in the <ENV name>.tfvars

variable "ENV" {
  type        = string
  description = "defines the name of the environment(dev, prod, etc). Should be defined as env variable, for example export TF_VAR_ENV=dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "labels" {
  default = {
    prefix = "myproject"
    stack  = "stackName"
  }
}

variable "component" {
  default = "componentName"
}

variable "vpc_id" {
  default = "vpc-change-me-123123"
}

variable "security_group" {
  default = {
    ingress_rules = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        description = "Allow SSH access"
        cidr_blocks = ["192.168.0.0/24"]
      },
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "Allow All access"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

}

# <ENV>.tfvars end
#################################################################################################################

#################################################  locals vars  #################################################
#if the value of a variable depends on the value of other variables, it should be defined in a locals block

locals {

  labels = merge(
    { env = var.ENV },
    { component = var.component },
    var.labels
  )

}

#################################################  module config  #################################################
# In module parameters recommend use terraform variables, because:
# - values can be environment dependent
# - this ComponentName.tf file - is more for component logic description, not for values definition
# - it is better to store vars values in one or two places(<ENV>.tfvars file and variables.tf)
module "test_security_group" {
  source        = "../../"
  vpc_id        = var.vpc_id
  ingress_rules = var.security_group.ingress_rules
  egress_rules  = var.security_group.egress_rules
  labels        = local.labels
}