# aws-subnet

Terraform module to create AWS Subnet.
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.public_ngw_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.public_ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability Zone where subnets will be created | `string` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | Base CIDR block which will be divided into subnet CIDR blocks (e.g. `10.0.0.0/16`) | `string` | `"null"` | no |
| <a name="input_igw_id"></a> [igw\_id](#input\_igw\_id) | Internet Gateway ID the public route table will point to | `string` | `""` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Minimum required map of labels(tags) for creating aws resources | <pre>object({<br>    prefix    = string<br>    stack     = string<br>    component = string<br>    env       = string<br>  })</pre> | n/a | yes |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Instances launched into a public subnet should be assigned a public IP address | `bool` | `true` | no |
| <a name="input_ngw_id"></a> [ngw\_id](#input\_ngw\_id) | NAT Gateway ID which will be used as a default route in private route tables | `string` | `""` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | optionally define a custom value for the subnet.<br>By default, it is defined as a construction from var.labels | `string` | `"default"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | Type of subnets (`private` or `public`) | `string` | `"private"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where subnets will be created (e.g. `vpc-aceb2723`) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ngw_id"></a> [ngw\_id](#output\_ngw\_id) | NAT Gateway ID |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | ID of the created public subnets |
<!-- END_TF_DOCS -->