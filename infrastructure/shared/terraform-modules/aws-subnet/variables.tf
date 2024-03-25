variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}

variable "type" {
  type        = string
  description = "Type of subnets (`private` or `public`)"
  default     = "private"
}

variable "subnet_name" {
  type        = string
  description = "define a name for the subnet"
  default     = "subnet-name"
}

variable "cidr_block" {
  type        = string
  description = "Base CIDR block which will be divided into subnet CIDR blocks (e.g. `10.0.0.0/16`)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where subnets will be created (e.g. `vpc-aceb2723`)"
}

variable "igw_id" {
  type        = string
  description = "Internet Gateway ID the public route table will point to"
  default     = ""
}

variable "ngw_id" {
  type        = string
  description = "Nat Gateway ID the public route table will point to"
  default     = ""
}

variable "ngw_enable" {
  type        = string
  description = "Create NAT Gateway in subnet"
  default     = false
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone where subnets will be created"
}

variable "map_public_ip_on_launch" {
  type        = bool
  default     = false
  description = "Instances launched into a public subnet should be assigned a public IP address"
}
