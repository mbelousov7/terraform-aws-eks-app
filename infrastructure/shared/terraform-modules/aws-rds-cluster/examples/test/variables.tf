locals {

  default_tags = {
    "environment-type" = lookup(var.environment_type, var.ENV, var.environment_type.sandbox)
    "service-name"     = var.stack
  }

  common_tags = {
    "Version" = var.components_versions.db
  }

  cloudteam_policy_arns = formatlist("arn:aws:iam::${var.account_number}:policy/%s", var.cloudteam_policy_names)

}
############################################################ environment variables ############################################################
# in this example, all variables are defined as default
# This is done to better understand the meaning of the variables.
# In a real environment, you should define variables in a variables.tf, the values of variables depending on the environment in the <ENV name>.tfvars

variable "ENV" {
  type        = string
  description = "defines the name of the environment(dev, prod, etc). Should be defined as env variable, for example export TF_VAR_ENV=dev"

  validation {
    condition     = contains(["dev", "preprod", "prod", "exampletest"], var.ENV)
    error_message = "Valid values for var are (dev, preprod, prod)."
  }
}

variable "environment_type" {
  default = {
    dev     = "DEVELOPMENT"
    preprod = "PRE-PRODUCTION"
    prod    = "PRODUCTION"
    sandbox = "SANDBOX"
  }
}

variable "prefix" {
  type    = string
  default = "myproject"
}

variable "stack" {
  default = "predictive-analytics"
}

variable "components_versions" {
  type = object({
    db = string
  })
  default = {
    db = "1.0.0"
  }
}

variable "account_number" {
  type    = string
  default = "497103815121"
}

############################################################ region and vpc variables ############################################################
variable "region_primary" {
  type    = string
  default = "us-east-1"
}

variable "availability_zones_primary" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "region_secondary" {
  type    = string
  default = "eu-west-1"
}

variable "availability_zones_secondary" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "vpc_id_primary" {
  type    = string
  default = "vpc-ak673rlksdfsafn"
}

variable "vpc_id_secondary" {
  type    = string
  default = "vpc-asdflk3klsadfkl"
}

variable "db_subnet_group_name_primary" {
  type        = string
  description = "existing group, manage by cloud team, using in aws_rds_cluster resource config, must contains restricted subnets id"
  default     = "dbs-subnetgroup-edp-analytics-sdlc-preprod-us-east-1"
}

variable "db_subnet_group_name_secondary" {
  type        = string
  description = "existing group, manage by cloud team, using in aws_rds_cluster resource config,  must contains restricted subnets id "
  default     = "dbs-subnetgroup-edp-analytics-sdlc-preprod-eu-west-1"
}

variable "security_group_cidr_blocks_allowed" {
  type        = list(string)
  description = "List of dev-preprod cidr blocks"
  default     = []
}

variable "security_groups_ids_allowed_primary" {
  type        = list(string)
  default     = []
  description = "List of security groups to be allowed to connect to the primary cluster"
}

variable "security_groups_ids_allowed_secondary" {
  type        = list(string)
  default     = []
  description = "List of security groups to be allowed to connect to the to the secondary cluster"
}

variable "security_group_ids_add_external_primary" {
  type        = list(string)
  description = "Additional security group IDs to apply to the primary cluster"
  default     = []
}

variable "security_group_ids_add_external_secondary" {
  type        = list(string)
  description = "Additional security group IDs to apply to the secondary cluster"
  default     = []
}

######################################################### db settings ##############################################################
variable "db_engine" {
  type        = string
  default     = "aurora-mysql"
  description = "The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
}

variable "db_engine_version" {
  type        = string
  description = "The version of the database engine to use. See `aws rds describe-db-engine-versions` "
  default     = "8.0.mysql_aurora.3.02.0"
}

variable "db_engine_family" {
  type        = string
  description = "The family of the DB cluster parameter group"
  default     = "aurora-mysql8.0"
}

variable "db_name" {
  type        = string
  default     = "predictiveanalytics"
  description = "Database name"
}

variable "cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default = [
    {
      name         = "require_secure_transport"
      value        = "ON"
      apply_method = "immediate"
    },
    {
      name         = "time_zone"
      value        = "UTC"
      apply_method = "immediate"
    },
    {
      name         = "tls_version"
      value        = "TLSv1.2"
      apply_method = "pending-reboot"
    }
  ]
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

variable "serverlessv2_scaling_configuration" {
  type = object({
    min_capacity = number
    max_capacity = number
  })
  description = "serverlessv2 scaling properties"
  default = {
    min_capacity = 0.5
    max_capacity = 2
  }
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB cluster is encrypted."
  default     = true
}

variable "cloudteam_policy_names" {
  default = ["cloud-service-policy-global-deny-1", "cloud-service-policy-global-deny-2"]
}
