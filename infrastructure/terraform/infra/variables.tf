//config from backend start
variable "region" {}
variable "vpc_name" {}
variable "tf_bucket" {}
variable "tf_stack" {}
variable "tf_zone" {}
variable "tf_key" {}
variable "dynamodb_table" {}
//config from backend end

variable "prefix" {
  type    = string
  default = "infra"
}

################################################################################
# EKS Cluster & IAM roles & Kubernetes resources count managment
################################################################################

variable "bootstrap_eks_count" {
  description = "0 - for stack init(if cluster not created yet), 1 - if cluster already created"
}

################################################################################
# VPC Configs
################################################################################

variable "region_to_short" {
  default = {
    "us-east-1" = "use1"
    "eu-west-1" = "ew1"
  }
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c", ]
}

################################################################################
# EKS Cluster
################################################################################

variable "eks_cluster_count" {
  default = 0
}

variable "ebs_csi_driver_iam_count" {
  default = 1
}


variable "eks_cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
  nullable    = false
}

variable "eks_cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = "172.20.0.0/16"
}

variable "eks_cluster_manage_aws_auth_configmap" {
  description = "Determines whether to manage the aws-auth configmap"
  type        = bool
  default     = true
}

variable "eks_cluster_admins_iam_roles" {
  description = <<-EOT
      eks admins iam roles, used for
      - aws_auth config: as rolearn and username
      - eks cluster kms key resource base policy as owners 
    EOT    
  type        = list(string)
  default     = []
}

variable "eks_cluster_viewers_iam_roles" {
  description = <<-EOT
      eks admins iam roles, used for
      - aws_auth config: as rolearn and username
      - eks cluster kms key resource base policy as viewers 
    EOT  
  type        = list(string)
  default     = []
}

variable "eks_cluster_managed_node_groups_default" {}
variable "eks_cluster_managed_node_groups" {}

variable "eks_cluster_security_group_rules_external_subnets" {
  default = {}
}

variable "public_dns_servers" {
  description = "DNS Servers to use when resolving external endpoints in special cases."
  type        = list(string)
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

################################################################################
# Karpenter
################################################################################

variable "karpenter_helm_chart_config" {}

variable "karpenter_helm_count" {
  default = 0
}

variable "karpenter_replicas_count" {
  default = 0
}

variable "karpenter_config_count" {
  default = 0
}

variable "karpenter_iam_count" {
  default = 0
}

################################################################################
# EKS ingress
################################################################################


variable "ingress_nginx_helm_count" {
  type    = number
  default = 0
}

variable "ingress_nginx_lb_count" {
  type    = number
  default = 0
}

variable "ingress_nginx_helm_chart_config" {
  description = "env dependent k8s ingress-nginx configs"
  type        = any
}


################################################################################
# ECR repos
################################################################################
variable "ecr_repos" {
  description = "A list of ECR repositories"
  type        = list(string)
  default     = []
}

################################################################################
# EKS Monitoring
################################################################################

variable "monitoring_enabled" {
  description = "1 - create monitoring helm charts and configs, 0 - skip monitoring configuration"
  validation {
    condition     = contains([0, 1], var.monitoring_enabled)
    error_message = "Invalid input, options: \"0\", \"1\"."
  }
  default = 1
}

variable "prometheus_eks_helm_chart_config" {
  description = "env dependent prometheus's configs"
  type        = any
}


################################################################################
# RDS Cluster
################################################################################


variable "db_component" {
}

variable "db_cluster_count" {
  type    = number
  default = 1
}

variable "db_cluster_size" {
  type        = number
  default     = 1
  description = "Number of DB instances to create in the  primary cluster"
}

variable "db_deletion_protection" {
  type        = bool
  description = "If the DB instance should have deletion protection enabled"
  default     = false
}

variable "db_engine" {
  type        = string
  default     = "aurora-mysql"
  description = "The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
}

variable "db_engine_version" {
  type        = string
  description = "The version of the database engine to use. See `aws rds describe-db-engine-versions` "
}

variable "db_engine_family" {
  type        = string
  description = "The family of the DB cluster parameter group"
}

variable "db_storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB cluster is encrypted."
  default     = true
}

variable "db_enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery"
  default     = ["error"]
}

variable "db_username" {
  type        = string
  default     = "admin"
  description = "database master username"
}

variable "db_pass_version" {
  type        = number
  description = "Password version. Increment this to trigger a new password."
  default     = 1
}

variable "db_cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default = [
    /*{
      name         = "require_secure_transport"
      value        = "OFF"
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
    },
    {
      name         = "max_allowed_packet"
      value        = "1073741824"
      apply_method = "immediate"
    },
    {
      name         = "max_connections"
      value        = "4000"
      apply_method = "pending-reboot"
    },
    {
      name         = "thread_stack"
      value        = "512000"
      apply_method = "pending-reboot"
    },*/

  ]
  description = "List of default DB cluster parameters to apply"
}

variable "db_cluster_parameters_env" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default = [
  ]
  description = "List of additional(env depended) DB cluster parameters to apply"
}

variable "db_instance_parameters" {
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
}

variable "db_instance_class" {
  type        = string
  default     = null
  description = "This setting is required to create a provisioned Multi-AZ DB cluster"
}

variable "db_storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)"
  default     = null
}

variable "db_iops" {
  type        = number
  description = <<-EOT
  The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'. This setting is required to create a Multi-AZ DB cluster. 
  Check TF docs for values based on db engine
  EOT
  default     = null
}

variable "db_allocated_storage" {
  type        = number
  description = "The allocated storage in GBs"
  default     = null
}


