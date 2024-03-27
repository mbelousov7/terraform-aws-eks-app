
output "vpc_id" {
  description = "ID of the created vpc"
  value       = module.vpc[0].vpc_id
}


output "priv_subnets" {
  description = "ID of the created vpc"
  value       = local.priv_subnets
}
