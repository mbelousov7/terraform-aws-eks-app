locals {

  default_tags = {
    Provisioner = "Terraform"
    "TF:Stack"  = var.tf_stack
    "TF:Zone"   = var.tf_zone
  }

}