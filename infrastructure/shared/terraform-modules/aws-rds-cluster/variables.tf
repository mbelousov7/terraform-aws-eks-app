variable "labels" {
  type = object({
    prefix    = string
    stack     = string
    component = string
    env       = string
  })
  description = "Minimum required map of labels(tags) for creating aws resources"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}

######################################## rds cluster definition vars ########################################

variable "cluster_type" {
  type        = string
  description = "defines the type of cluster instance(primary or secondary"
  default     = "primary"
  validation {
    condition     = contains(["primary", "secondary"], var.cluster_type)
    error_message = "Valid values for var are (primary, secondary)."
  }
}

variable "cluster_size" {
  type        = number
  default     = 2
  description = "Number of DB instances to create in the cluster"
}

variable "global_cluster_identifier" {
  type        = string
  description = "ID of the global Aurora cluster"
  //default     = ""
}

variable "cluster_name" {
  type        = string
  description = "subname of the Aurora cluster"
  //default     = ""
}

variable "cluster_custom_endpoint" {
  type        = bool
  description = "true - if you need to deploy additional custom reader endpoint"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the cluster in (e.g. `vpc-a394745sdf`)"
}

variable "db_engine" {
  type        = string
  default     = "aurora-mysql"
  description = "The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
}

variable "db_engine_version" {
  type        = string
  default     = ""
  description = "The version of the database engine to use. See `aws rds describe-db-engine-versions` "
}

variable "db_engine_family" {
  type        = string
  default     = "aurora-mysql8.0"
  description = "The family of the DB cluster parameter group"
}

variable "db_name" {
  type        = string
  default     = ""
  description = "Database name (default is not to create a database)"
}

variable "cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = []
  description = "List of DB cluster parameters to apply"
}

variable "instance_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = []
  description = "List of DB instance parameters to apply"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = false
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
}

variable "db_instance_class" {
  type        = string
  default     = null
  description = "This setting is required to create a provisioned Multi-AZ DB cluster"
}

variable "engine_mode" {
  type        = string
  default     = "provisioned"
  description = "The database engine mode. Valid values: `parallelquery`, `provisioned`, `serverless`"
}

variable "serverlessv2_scaling_configuration" {
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default     = null
  description = "serverlessv2 scaling properties"
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB cluster is encrypted."
  default     = true
}

variable "storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)"
  default     = null
}

variable "iops" {
  type        = number
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'. This setting is required to create a Multi-AZ DB cluster. Check TF docs for values based on db engine"
  default     = null
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage in GBs"
  default     = null
}

variable "source_region" {
  type        = string
  description = "Source Region of primary cluster, needed when using encrypted storage and region replicas"
  default     = ""
}

variable "availability_zones" {
  type = list(string)
}

variable "instance_availability_zone" {
  type    = string
  default = null
}

variable "instance_availability_zone_reader" {
  type    = string
  default = null
}

variable "security_group_cidr_blocks_allowed" {
  type        = list(string)
  default     = []
  description = "List of cidr blocks to be allowed to connect to the DB instance"
}

variable "security_groups_ids_allowed" {
  type        = list(string)
  default     = []
  description = "List of security groups to be allowed to connect to the DB instance"
}

variable "security_group_ids_add_external" {
  type        = list(string)
  description = "Additional security group IDs to apply to the cluster"
  default     = []
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN for the KMS encryption key. When specifying `kms_key_arn`, `storage_encrypted` needs to be set to `true`"
  default     = ""
}

variable "master_username" {
  type        = string
  default     = "admin"
  description = "Username for the master DB user. Ignored if cluster_type == secondary"
}

variable "master_password" {
  type        = string
  default     = ""
  description = "Password for the master DB user. Ignored if cluster_type == secondary"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  default     = true
}

variable "iam_roles" {
  type        = list(string)
  description = "Iam roles for the Aurora cluster"
  default     = []
}

variable "retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain backups for"
}

variable "backup_window" {
  type        = string
  default     = "02:00-03:00"
  description = "Daily time range during which the backups happen"
}

variable "copy_tags_to_snapshot" {
  type        = bool
  description = "Copy tags to backup snapshots"
  default     = true
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
  default     = true
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  default     = true
}

variable "db_subnet_group_name" {
  type        = string
  description = "Database subnet group name."
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery"
  default     = []
}

variable "deletion_protection" {
  type        = bool
  description = "If the DB instance should have deletion protection enabled"
  default     = false
}

variable "allow_major_version_upgrade" {
  type        = bool
  default     = false
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to false."
}

variable "performance_insights_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable Performance Insights"
}

variable "performance_insights_kms_key_id" {
  type        = string
  default     = ""
  description = "The ARN for the KMS key to encrypt Performance Insights data. When specifying `performance_insights_kms_key_id`, `performance_insights_enabled` needs to be set to true"
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)"
  type        = number
  default     = 7
}

######################################## alarm configs #######################################

variable "alarm_enable" {
  type    = bool
  default = true
}

variable "alarm_topic_arn" {
  type    = string
  default = ""
}

variable "alarm_config" {
  type        = string
  default     = ""
  description = "add custom string into alarm descritptioon"
}

variable "cpu_utilization_threshold" {
  description = "The maximum percentage of CPU utilization."
  type        = number
  default     = 90
}

variable "memory_utilization_threshold" {
  description = "The minimum avaliable GB of Memory utilization."
  type        = number
  default     = 4
}

variable "aborted_clients_threshold" {
  description = "The minimum task count threshold"
  type        = number
  default     = 50
}

variable "volume_read_iops_threshold" {
  type    = number
  default = 1.5
}

variable "volume_write_iops_threshold" {
  type    = number
  default = 1.5
}

variable "alarm_log_configs" {
  /*
  type = map(object({
  }))
  */
  default = {
    slowquery = {
      metric_name               = "slowquery"
      filter_pattern            = "\"Time\""
      metric_value              = "1"
      metric_default_value      = "0"
      alarm_name                = "slowquery"
      alarm_comparison_operator = "GreaterThanThreshold"
      alarm_evaluation_periods  = 60
      alarm_period              = 60
      alarm_statistic           = "Sum"
      alarm_treat_missing_data  = "notBreaching"
      alarm_threshold           = 5
      alarm_description         = "Multiple slowqueres in log files"
    }

  }

  description = "The cloudwatch metrics filters definitions"
}

variable "db_port" {
  type    = number
  default = 3306
}