######################################## names, labels, tags ########################################
variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}

variable "vpc_name" {
  type        = string
  description = <<-EOT
      define name for the vpc.
    EOT
  default     = "vpc-name"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = <<-EOT
      Set `true` to enable
       [DNS hostnames](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html#vpc-dns-hostnames) in the VPC
    EOT
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Set `true` to enable DNS resolution in the VPC through the Amazon provided DNS server"
  default     = true
}

variable "igw_enable" {
  type        = bool
  description = <<-EOT
      optionally define if it not necessary to deploy internet gateway for vpc
    EOT
  default     = true
}

variable "igw_name" {
  type        = string
  description = <<-EOT
      define name for the internet gateway name.
    EOT
  default     = "igw-name"
}

variable "dsg_name" {
  type        = string
  description = <<-EOT
      define name for the default security group name.
    EOT
  default     = "dsg-name"
}

variable "cidr_block" {
  type        = string
  description = "IPv4 CIDR to assign to the VPC"
}

variable "default_security_group_deny_all" {
  type        = bool
  default     = true
  description = <<-EOT
    When `true`, manage the default security group and remove all rules, disabling all ingress and egress.
    When `false`, do not manage the default security group, allowing it to be managed by another component
    EOT
}
