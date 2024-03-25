data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "all_priv" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*1a", "*1b", "*1c"]
  }
  tags = {
    Type = "private"
  }
}

data "aws_subnets" "all_pub" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*1a", "*1b", "*1c"]
  }
  tags = {
    Type = "public"
  }
}

data "aws_subnet" "all_priv_subnet" {
  for_each = toset(data.aws_subnets.all_priv.ids)
  id       = each.value
}

data "aws_subnet" "all_pub_subnet" {
  for_each = toset(data.aws_subnets.all_pub.ids)
  id       = each.value
}

locals {


  priv_subnets     = [for s in data.aws_subnets.all_priv.ids : s]
  priv_cidr_blocks = [for subnet_id, subnet_data in data.aws_subnet.all_priv_subnet : subnet_data.cidr_block]

  pub_subnets     = [for s in data.aws_subnets.all_pub.ids : s]
  pub_cidr_blocks = [for subnet_id, subnet_data in data.aws_subnet.all_pub_subnet : subnet_data.cidr_block]

  priv_subnets_1a = [for s in data.aws_subnet.all_priv_subnet : s.id if s.availability_zone == "${var.region}a"]
  priv_subnets_1b = [for s in data.aws_subnet.all_priv_subnet : s.id if s.availability_zone == "${var.region}b"]
  priv_subnets_1c = [for s in data.aws_subnet.all_priv_subnet : s.id if s.availability_zone == "${var.region}c"]

}


