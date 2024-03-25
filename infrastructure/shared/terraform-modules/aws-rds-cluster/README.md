# tf-aws-rds-cluster

Terraform module to create AWS RDS multy region cluster.

terrafrom module config exampl see [examples/test](examples/test)


Terraform versions tested
- 1.1.8

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_security_group"></a> [aws\_security\_group](#module\_aws\_security\_group) | ./aws_security_group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_metric_filter.slowquery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.aborted_clients](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.slowquery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.volume_read_iops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.volume_write_iops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_db_parameter_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_rds_cluster.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_endpoint.primary_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_endpoint) | resource |
| [aws_rds_cluster_endpoint.secondary_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_endpoint) | resource |
| [aws_rds_cluster_instance.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_instance.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_parameter_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aborted_clients_threshold"></a> [aborted\_clients\_threshold](#input\_aborted\_clients\_threshold) | The minimum task count threshold | `number` | `50` | no |
| <a name="input_alarm_config"></a> [alarm\_config](#input\_alarm\_config) | add custom string into alarm descritptioon | `string` | `""` | no |
| <a name="input_alarm_enable"></a> [alarm\_enable](#input\_alarm\_enable) | n/a | `bool` | `true` | no |
| <a name="input_alarm_log_configs"></a> [alarm\_log\_configs](#input\_alarm\_log\_configs) | The cloudwatch metrics filters definitions | `map` | <pre>{<br>  "slowquery": {<br>    "alarm_comparison_operator": "GreaterThanThreshold",<br>    "alarm_description": "Multiple slowqueres in log files",<br>    "alarm_evaluation_periods": 60,<br>    "alarm_name": "slowquery",<br>    "alarm_period": 60,<br>    "alarm_statistic": "Sum",<br>    "alarm_threshold": 5,<br>    "alarm_treat_missing_data": "notBreaching",<br>    "filter_pattern": "\"Time\"",<br>    "metric_default_value": "0",<br>    "metric_name": "slowquery",<br>    "metric_value": "1"<br>  }<br>}</pre> | no |
| <a name="input_alarm_topic_arn"></a> [alarm\_topic\_arn](#input\_alarm\_topic\_arn) | n/a | `string` | `""` | no |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The allocated storage in GBs | `number` | `null` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Enable to allow major engine version upgrades when changing engine versions. Defaults to false. | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window | `bool` | `true` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window | `bool` | `false` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | n/a | `list(string)` | n/a | yes |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Daily time range during which the backups happen | `string` | `"02:00-03:00"` | no |
| <a name="input_cluster_custom_endpoint"></a> [cluster\_custom\_endpoint](#input\_cluster\_custom\_endpoint) | true - if you need to deploy additional custom reader endpoint | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | subname of the Aurora cluster | `string` | n/a | yes |
| <a name="input_cluster_parameters"></a> [cluster\_parameters](#input\_cluster\_parameters) | List of DB cluster parameters to apply | <pre>list(object({<br>    apply_method = string<br>    name         = string<br>    value        = string<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | Number of DB instances to create in the cluster | `number` | `2` | no |
| <a name="input_cluster_type"></a> [cluster\_type](#input\_cluster\_type) | defines the type of cluster instance(primary or secondary | `string` | `"primary"` | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Copy tags to backup snapshots | `bool` | `true` | no |
| <a name="input_cpu_utilization_threshold"></a> [cpu\_utilization\_threshold](#input\_cpu\_utilization\_threshold) | The maximum percentage of CPU utilization. | `number` | `90` | no |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql` | `string` | `"aurora-mysql"` | no |
| <a name="input_db_engine_family"></a> [db\_engine\_family](#input\_db\_engine\_family) | The family of the DB cluster parameter group | `string` | `"aurora-mysql8.0"` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | The version of the database engine to use. See `aws rds describe-db-engine-versions` | `string` | `""` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | This setting is required to create a provisioned Multi-AZ DB cluster | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database name (default is not to create a database) | `string` | `""` | no |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | n/a | `number` | `3306` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | Database subnet group name. | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the DB instance should have deletion protection enabled | `bool` | `false` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery | `list(string)` | `[]` | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | The database engine mode. Valid values: `parallelquery`, `provisioned`, `serverless` | `string` | `"provisioned"` | no |
| <a name="input_global_cluster_identifier"></a> [global\_cluster\_identifier](#input\_global\_cluster\_identifier) | ID of the global Aurora cluster | `string` | n/a | yes |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled | `bool` | `true` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | Iam roles for the Aurora cluster | `list(string)` | `[]` | no |
| <a name="input_instance_availability_zone"></a> [instance\_availability\_zone](#input\_instance\_availability\_zone) | n/a | `string` | `null` | no |
| <a name="input_instance_availability_zone_reader"></a> [instance\_availability\_zone\_reader](#input\_instance\_availability\_zone\_reader) | n/a | `string` | `null` | no |
| <a name="input_instance_parameters"></a> [instance\_parameters](#input\_instance\_parameters) | List of DB instance parameters to apply | <pre>list(object({<br>    apply_method = string<br>    name         = string<br>    value        = string<br>  }))</pre> | `[]` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of provisioned IOPS. Setting this implies a storage\_type of 'io1'. This setting is required to create a Multi-AZ DB cluster. Check TF docs for values based on db engine | `number` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN for the KMS encryption key. When specifying `kms_key_arn`, `storage_encrypted` needs to be set to `true` | `string` | `""` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Minimum required map of labels(tags) for creating aws resources | <pre>object({<br>    prefix    = string<br>    stack     = string<br>    component = string<br>    env       = string<br>  })</pre> | n/a | yes |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | Password for the master DB user. Ignored if cluster\_type == secondary | `string` | `""` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Username for the master DB user. Ignored if cluster\_type == secondary | `string` | `"admin"` | no |
| <a name="input_memory_utilization_threshold"></a> [memory\_utilization\_threshold](#input\_memory\_utilization\_threshold) | The minimum avaliable GB of Memory utilization. | `number` | `4` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Whether to enable Performance Insights | `bool` | `true` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | The ARN for the KMS key to encrypt Performance Insights data. When specifying `performance_insights_kms_key_id`, `performance_insights_enabled` needs to be set to true | `string` | `""` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years) | `number` | `7` | no |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | Number of days to retain backups for | `number` | `7` | no |
| <a name="input_security_group_cidr_blocks_allowed"></a> [security\_group\_cidr\_blocks\_allowed](#input\_security\_group\_cidr\_blocks\_allowed) | List of cidr blocks to be allowed to connect to the DB instance | `list(string)` | `[]` | no |
| <a name="input_security_group_ids_add_external"></a> [security\_group\_ids\_add\_external](#input\_security\_group\_ids\_add\_external) | Additional security group IDs to apply to the cluster | `list(string)` | `[]` | no |
| <a name="input_security_groups_ids_allowed"></a> [security\_groups\_ids\_allowed](#input\_security\_groups\_ids\_allowed) | List of security groups to be allowed to connect to the DB instance | `list(string)` | `[]` | no |
| <a name="input_serverlessv2_scaling_configuration"></a> [serverlessv2\_scaling\_configuration](#input\_serverlessv2\_scaling\_configuration) | serverlessv2 scaling properties | <pre>object({<br>    min_capacity = number<br>    max_capacity = number<br>  })</pre> | `null` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB cluster is deleted | `bool` | `true` | no |
| <a name="input_source_region"></a> [source\_region](#input\_source\_region) | Source Region of primary cluster, needed when using encrypted storage and region replicas | `string` | `""` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB cluster is encrypted. | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_volume_read_iops_threshold"></a> [volume\_read\_iops\_threshold](#input\_volume\_read\_iops\_threshold) | n/a | `number` | `1.5` | no |
| <a name="input_volume_write_iops_threshold"></a> [volume\_write\_iops\_threshold](#input\_volume\_write\_iops\_threshold) | n/a | `number` | `1.5` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to create the cluster in (e.g. `vpc-a394745sdf`) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The DNS address of the RDS instance |
| <a name="output_endpoint_reader"></a> [endpoint\_reader](#output\_endpoint\_reader) | The DNS address of the RDS instance |
| <a name="output_endpoint_reader_custom"></a> [endpoint\_reader\_custom](#output\_endpoint\_reader\_custom) | The DNS address of the RDS instance |
| <a name="output_id"></a> [id](#output\_id) | RDS cluster id |
| <a name="output_port"></a> [port](#output\_port) | RDS instance port to connect |
| <a name="output_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#output\_vpc\_security\_group\_ids) | security group ids |
<!-- END_TF_DOCS -->