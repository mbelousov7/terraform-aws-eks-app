################################################################################
# VPC Info
################################################################################

output "priv_subnets" {
  description = "priv_subnets details."
  value       = local.priv_subnets
}

################################################################################
# Cluster Info
################################################################################
output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "cluster_endpoint details."
  value       = module.eks.cluster_endpoint
}

output "oidc_provider" {
  description = "oidc_provider details."
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "oidc_provider_arn details."
  value       = module.eks.oidc_provider_arn
}

output "eks_aws_auth_roles" {
  description = "eks_aws_auth_roles details."
  value       = local.eks_aws_auth_roles
}


################################################################################
# URL Info
################################################################################

output "prometheus" {
  value = "http://${join("", data.aws_lb.ingress_nginx.*.dns_name)}/prometheus"
}