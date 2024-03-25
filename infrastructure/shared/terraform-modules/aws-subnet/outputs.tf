output "subnet_id" {
  description = "ID of the created subnet"
  value = coalescelist(
    aws_subnet.private.*.id,
    aws_subnet.public.*.id
  )[0]
}

output "ngw_id" {
  value       = join("", aws_nat_gateway.public.*.id)
  description = "NAT Gateway ID"
}

output "route_table_id" {
  value = coalescelist(
    aws_route_table.private.*.id,
    aws_route_table.public.*.id
  )[0]
  description = "Route table ID"
}