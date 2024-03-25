data "aws_caller_identity" "current" {}

locals {

  default_tags = {
    Provisioner = "Terraform"
    "TF:Stack"  = var.tf_stack
    "TF:Zone"   = var.tf_zone
  }



  region_short = lookup(var.region_to_short, var.region, var.region)

  account_id = data.aws_caller_identity.current.account_id



}

