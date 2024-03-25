# tf-aws-security-group

Terraform module to create AWS Security Group with rules.

terrafrom config example:

```
locals {
  labels = merge(
    { env = var.ENV },
    { component = "componentName" },
    var.labels
  )
}

module "test_security_group" {
  source        = "../../"
  vpc_id        = var.vpc_config.vpc_id
  ingress_rules = var.security_group.ingress_rules
  egress_rules  = var.security_group.egress_rules
  labels        = local.labels
}
```
more info see [examples/test](examples/test)


terraform run example

```
cd examples/test
export TF_VAR_ENV="exampletest"
terraform init
terraform plan
``` 

Terraform versions tested
- 0.15.3
- 1.1.8

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
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | The map of security group egress rules | <pre>list(object({<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>    description = string<br>    cidr_blocks = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | The map of security group ingress rules | <pre>list(object({<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>    description = string<br>    cidr_blocks = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Minimum required map of labels(tags) for creating aws resources | <pre>object({<br>    prefix    = string<br>    stack     = string<br>    component = string<br>    env       = string<br>  })</pre> | n/a | yes |
| <a name="input_revoke_rules_on_delete"></a> [revoke\_rules\_on\_delete](#input\_revoke\_rules\_on\_delete) | Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules before deleting<br>the security group itself. This is normally not needed. | `bool` | `false` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | The description to assign to the created Security Group.<br>Warning: Changing the description causes the security group to be replaced. | `string` | `"Managed by Terraform"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the Security Group will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The created Security Group ID |
<!-- END_TF_DOCS -->