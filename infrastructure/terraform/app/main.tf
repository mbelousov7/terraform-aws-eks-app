data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "${var.tf_bucket}"
    region = "${var.region}"
    key    = "terraform/infra/terraform-aws-eks-app-infra-state-${var.region}.tfstate"
  }
  workspace = var.tf_zone

}

locals {
  eks_cluster_name = data.terraform_remote_state.infra.outputs.cluster_name
}

/*
kube configs examples if eks cluster already created
use it as workaround to fix next terraform error
Error: Get "http://localhost/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/viewer": dial tcp 127.0.0.1:80: connect: connection refused
after fix switch back to kube configs if eks not created yet
*/

data "aws_eks_cluster" "eks" {
  count = var.cluster_is_deployed ? 1 : 0
  name  = local.eks_cluster_name //module.eks.cluster_name
  //depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  count = var.cluster_is_deployed ? 1 : 0
  name  = local.eks_cluster_name //module.eks.cluster_name
  //depends_on = [module.eks]
}

provider "helm" {
  alias = "eks"
  kubernetes {
    host                   = join("", data.aws_eks_cluster.eks.*.endpoint)
    cluster_ca_certificate = base64decode(join("", data.aws_eks_cluster.eks.*.certificate_authority.0.data))
    token                  = join("", data.aws_eks_cluster_auth.eks.*.token)
  }
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = join("", data.aws_eks_cluster.eks.*.endpoint)
  cluster_ca_certificate = base64decode(join("", data.aws_eks_cluster.eks.*.certificate_authority.0.data))
  token                  = join("", data.aws_eks_cluster_auth.eks.*.token)
}


provider "aws" {
  region = var.region
  default_tags {
    tags = local.default_tags
  }
}

terraform {
  backend "s3" {
    # see detailed bucket configuration in configs/backend/<ENV>.sh file
  }

  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.00"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.2"
    }
  }
}


