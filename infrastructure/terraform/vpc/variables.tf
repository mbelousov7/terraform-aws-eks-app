//config from backend start
variable "region" {}
variable "tf_bucket" {}
variable "tf_stack" {}
variable "tf_zone" {}
variable "tf_key" {}
variable "dynamodb_table" {}
//config from backend end

############################################################ region and vpc variables ############################################################

variable "vpc_config" {

  type = object({
    //component                  = string
    //availability_zones = list(string)
    vpc_cidr_block = string
    igw_enable     = bool
    //subnet_public_cidr_blocks  = list(string)
    //subnet_private_cidr_blocks = list(string)
  })

}

variable "subnets_config_private" {

}

variable "subnets_config_public" {

}

