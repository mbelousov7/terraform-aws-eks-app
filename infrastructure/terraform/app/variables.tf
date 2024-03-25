//config from backend start
variable "region" {}
variable "vpc_name" {}
variable "tf_bucket" {}
variable "tf_stack" {}
variable "tf_zone" {}
variable "tf_env" {}
variable "tf_key" {}
variable "dynamodb_table" {}
//config from backend end

variable "prefix" {
  type    = string
  default = "kutt"
}


################################################################################
# EKS Cluster & IAM roles & Kubernetes resources count managment
################################################################################

variable "bootstrap_eks_count" {
  description = "0 - for stack init(if cluster not created yet), 1 - if cluster already created"
  default     = 1
}

############################################### regions and vpc's variables ############################################################

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "cloudfront_count" {
  default = 0
}

################################################################################
# Polr configs  
################################################################################

variable "polr_helm_count" {
  default = 0
}


variable "polr_db_secret_name" {
}

