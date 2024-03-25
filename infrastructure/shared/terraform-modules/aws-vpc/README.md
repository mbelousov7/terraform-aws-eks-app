# tf-aws-vpc

Terraform module to create AWS VPC.


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
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_internet_gateway.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | IPv4 CIDR to assign to the VPC | `string` | n/a | yes |
| <a name="input_default_security_group_deny_all"></a> [default\_security\_group\_deny\_all](#input\_default\_security\_group\_deny\_all) | When `true`, manage the default security group and remove all rules, disabling all ingress and egress.<br>When `false`, do not manage the default security group, allowing it to be managed by another component | `bool` | `true` | no |
| <a name="input_dsg_name"></a> [dsg\_name](#input\_dsg\_name) | optionally define a custom value for the default security group name.<br>By default, it is defined as a construction from var.labels | `string` | `"default"` | no |
| <a name="input_igw_name"></a> [igw\_name](#input\_igw\_name) | optionally define a custom value for the internet gateway name.<br>By default, it is defined as a construction from var.labels | `string` | `"default"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Minimum required map of labels(tags) for creating aws resources | <pre>object({<br>    prefix    = string<br>    stack     = string<br>    component = string<br>    env       = string<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | optionally define a custom value for the vpc.<br>By default, it is defined as a construction from var.labels | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | The ID of the Internet Gateway |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_default_route_table_id"></a> [vpc\_default\_route\_table\_id](#output\_vpc\_default\_route\_table\_id) | The ID of the route table created by default on VPC creation |
| <a name="output_vpc_default_security_group_id"></a> [vpc\_default\_security\_group\_id](#output\_vpc\_default\_security\_group\_id) | The ID of the security group created by default on VPC creation |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_main_route_table_id"></a> [vpc\_main\_route\_table\_id](#output\_vpc\_main\_route\_table\_id) | The ID of the main route table associated with this VPC |
<!-- END_TF_DOCS -->