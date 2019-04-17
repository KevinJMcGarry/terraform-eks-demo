# IGW for resources in the public subnet
resource "aws_internet_gateway" "eks-demo-igw" {
  vpc_id = "${aws_vpc.terraform-eks-demo.id}"

  tags {
    Name = "eks_demo_internet_gateway"
  }
}

# create n number of elastic ips
resource "aws_eip" "nat_gateway" {
  count = "${var.subnet_count}"
  vpc      = true
}

# create and associate a separate nat gateway for each targeted AZ subnet
# see https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
resource "aws_nat_gateway" "eks_demo_nat_gateway" {
  count = "${var.subnet_count}"
  allocation_id = "${aws_eip.nat_gateway.*.id[count.index]}" # the Allocation ID of the Elastic IP addresses for the gateways
  subnet_id = "${aws_subnet.gateway.*.id[count.index]}"  # the subnet ID of the subnet in which to place the gateway
  tags {
    Name = "eks_demo_nat_gateway"
  }
  depends_on = ["aws_internet_gateway.eks-demo-igw"]
}
