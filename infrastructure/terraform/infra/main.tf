/*
kube configs examples if eks cluster already created
use it as workaround to fix next terraform error
Error: Get "http://localhost/apis/rbac.authorization.k8s.io/v1/clusterrolebindings/viewer": dial tcp 127.0.0.1:80: connect: connection refused
after fix switch back to kube configs if eks not created yet
*/

data "aws_eks_cluster" "eks" {
  count = var.bootstrap_eks_count
  name  = local.eks_cluster_name //module.eks.cluster_name
  //depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  count = var.bootstrap_eks_count
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


/*
kube configs if eks not created yet
use it as default configuration
*/

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "null")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "null")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
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


