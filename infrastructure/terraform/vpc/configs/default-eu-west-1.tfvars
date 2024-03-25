
vpc_config = {
  vpc_cidr_block = "10.10.0.0/16"
  igw_enable     = true
}

/*
priv-eu-west-1
Subnet 1: 10.10.0.0/20
Subnet 2: 10.10.16.0/20
Subnet 3: 10.10.32.0/20
priv-eu-west-2 //reserved for secondary region
Subnet 4: 10.10.48.0/20
Subnet 5: 10.10.64.0/20
Subnet 6: 10.10.80.0/20

pub-eu-west-1
Subnet 7: 10.10.96.0/20
Subnet 8: 10.10.112.0/20
Subnet 9: 10.10.128.0/20

pub-eu-west-2 //reserved for secondary region
Subnet 10: 10.10.144.0/20
Subnet 11: 10.10.160.0/20
Subnet 12: 10.10.176.0/20
*/

subnets_config_private = {

  eu-west-1a = {
    cidr_blocks = ["10.10.0.0/20"]
  }

  eu-west-1b = {
    cidr_blocks = ["10.10.16.0/20"]
  }

  eu-west-1c = { cidr_blocks = ["10.10.32.0/20"] }

}


subnets_config_public = {

  eu-west-1a = {
    cidr_blocks = ["10.10.96.0/20"]
  }

  eu-west-1b = {
    cidr_blocks = ["10.10.112.0/20"]
  }

  eu-west-1c = { cidr_blocks = ["10.10.128.0/20"] }

}