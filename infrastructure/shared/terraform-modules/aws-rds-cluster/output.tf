output "endpoint" {
  value       = var.cluster_type == "primary" ? join("", aws_rds_cluster.primary.*.endpoint) : join("", aws_rds_cluster.secondary.*.endpoint)
  description = "The DNS address of the RDS instance"
}

output "endpoint_reader" {
  value       = var.cluster_type == "primary" ? join("", aws_rds_cluster.primary.*.reader_endpoint) : join("", aws_rds_cluster.secondary.*.reader_endpoint)
  description = "The DNS address of the RDS instance"
}

output "endpoint_reader_custom" {
  value       = var.cluster_type == "primary" ? join("", aws_rds_cluster_endpoint.primary_reader.*.endpoint) : join("", aws_rds_cluster_endpoint.secondary_reader.*.endpoint)
  description = "The DNS address of the RDS instance"
}

output "port" {
  value       = var.cluster_type == "primary" ? join("", aws_rds_cluster.primary.*.port) : join("", aws_rds_cluster.secondary.*.port)
  description = "RDS instance port to connect"
}

output "id" {
  value       = var.cluster_type == "primary" ? join("", aws_rds_cluster.primary.*.id) : join("", aws_rds_cluster.secondary.*.id)
  description = "RDS cluster id"
}

output "vpc_security_group_ids" {
  value       = compact(flatten([[module.aws_security_group.id], var.security_group_ids_add_external]))
  description = "security group ids"
}
