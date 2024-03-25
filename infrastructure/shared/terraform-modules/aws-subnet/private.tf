locals {
  private_count     = var.type == "private" ? 1 : 0
  private_ngw_count = var.type == "private" && var.ngw_enable ? 1 : 0
}

resource "aws_subnet" "private" {
  count                   = local.private_count
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

resource "aws_route_table" "private" {
  count  = local.private_count
  vpc_id = data.aws_vpc.default.id
  tags = merge(
    var.tags,
    { Name = local.subnet_name },
    { Network = var.type },
  )
}


resource "aws_route" "private_ngw" {
  count                  = local.private_ngw_count
  route_table_id         = join("", aws_route_table.private.*.id)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.ngw_id
}

resource "aws_route_table_association" "private" {
  count          = local.private_ngw_count
  subnet_id      = join("", aws_subnet.private.*.id)
  route_table_id = join("", aws_route_table.private.*.id)
}



