# Gateway subnets (public subnets) use the previously built Internet Gateway to allow connections in and out, 
# and the application subnets use the NAT Gateways to connect to the internet

# Create Route Tables
resource "aws_route_table" "gateway" {
  vpc_id = "${aws_vpc.terraform-eks-demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks-demo-igw.id}"
  }
  tags {
    Name = "public_subnet_rt"
  }
}

# creating a route table for each nat gateway (id[0], id[1], id[2])
resource "aws_route_table" "application" {
  count = "${var.subnet_count}"
  vpc_id = "${aws_vpc.terraform-eks-demo.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.eks_demo_nat_gateway.*.id[count.index]}"
  }
  tags {
    Name = "eks_demo_application_rt"
  }
}

resource "aws_route_table" "database" {
  vpc_id = "${aws_vpc.terraform-eks-demo.id}"

  tags {
    Name = "eks_demo_database_rt"
  }
}


# Create Route Table/Subnet Associations
resource "aws_route_table_association" "gateway" {
  count = "${var.subnet_count}"

  subnet_id      = "${aws_subnet.gateway.*.id[count.index]}"
  route_table_id = "${aws_route_table.gateway.id}"
}

resource "aws_route_table_association" "application" {
  count = "${var.subnet_count}"

  subnet_id      = "${aws_subnet.application.*.id[count.index]}"
  route_table_id = "${aws_route_table.application.*.id[count.index]}"
}

resource "aws_route_table_association" "database" {
  count = "${var.subnet_count}"

  subnet_id      = "${aws_subnet.database.*.id[count.index]}"
  route_table_id = "${aws_route_table.database.id}"
}
