locals {
  public_count     = var.type == "public" ? 1 : 0
  public_ngw_count = var.type == "public" && var.ngw_enable ? 1 : 0

  igw_id = var.igw_id == "" ? null : var.igw_id

}

resource "aws_subnet" "public" {
  count                   = local.public_count
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = var.availability_zone
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = merge(
    var.tags,
    { Name = local.subnet_name },
    { Type = var.type },
  )
}

resource "aws_route_table" "public" {
  count  = local.public_count
  vpc_id = data.aws_vpc.default.id
  tags = merge(
    var.tags,
    { Name = local.subnet_name },
    { Type = var.type },
  )
}

resource "aws_route" "public" {
  count                  = local.public_count
  route_table_id         = join("", aws_route_table.public.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = local.igw_id
}

resource "aws_route_table_association" "public" {
  count          = local.public_count
  subnet_id      = join("", aws_subnet.public.*.id)
  route_table_id = join("", aws_route_table.public.*.id)
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "public_ngw_eip" {
  count  = local.public_ngw_count
  domain = "vpc"
  tags = merge(
    var.tags,
    { Name = local.ngw_name },
  )
}

# NAT
resource "aws_nat_gateway" "public" {
  count         = local.public_ngw_count
  allocation_id = join("", aws_eip.public_ngw_eip.*.id)
  subnet_id     = join("", aws_subnet.public.*.id)

  tags = merge(
    var.tags,
    { Name = local.ngw_name },

  )
}



