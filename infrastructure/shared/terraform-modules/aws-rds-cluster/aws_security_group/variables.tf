variable "name" {
  type = string
}

variable "base_tags" {
  type    = map(string)
  default = {}
}

variable "db_port" {
  type    = number
  default = 3306
}


variable "vpc_id" {
  type = string
}

variable "cidr_blocks_allowed" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks allowed to access the cluster"
}

variable "security_groups_allowed" {
  type        = list(string)
  default     = []
  description = "List of security groups to be allowed to connect to the DB instance"
}