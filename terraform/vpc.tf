###################################################################
# VPC
resource "aws_vpc" "PrimerVPC" {
  cidr_block = "${var.VPCCidrP}"

  tags {
    Name = "ELK"
  }
}

resource "aws_subnet" "PublicSubnetA" {
  vpc_id     = "${aws_vpc.PrimerVPC.id}"
  cidr_block = "${var.Subnet1}"
  map_public_ip_on_launch = true
  tags {
    Name = "ELK-SubnetA"
  }
}

resource "aws_subnet" "PublicSubnetB" {
  vpc_id     = "${aws_vpc.PrimerVPC.id}"
  cidr_block = "${var.Subnet2}"
  map_public_ip_on_launch = true
  tags {
    Name = "ELK-SubnetB"
  }
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id     = "${aws_vpc.PrimerVPC.id}"

  tags {
    Name = "ELK-IGW"
  }
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id     = "${aws_vpc.PrimerVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.InternetGateway.id}"
  }

  tags {
    Name = "ELK-PublicRouteTable"
  }
}

resource "aws_route_table_association" "SubnetRouteAssociateA" {
  subnet_id      = "${aws_subnet.PublicSubnetA.id}"
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
}

resource "aws_route_table_association" "SubnetRouteAssociateB" {
  subnet_id      = "${aws_subnet.PublicSubnetB.id}"
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
}

