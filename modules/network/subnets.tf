# fetch and create list of available AZs for the region
data "aws_availability_zones" "available" {}

resource "aws_subnet" "gateway" {
  count = "${var.subnet_count}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.1.1${count.index}.0/24"
  vpc_id            = "${aws_vpc.terraform-eks-demo.id}"
  tags = "${
    map(
     "Name", "terraform-eks-demo-public_subnet_gateway"
    )
  }"
}
resource "aws_subnet" "application" {
  count = "${var.subnet_count}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.1.2${count.index}.0/24"
  vpc_id            = "${aws_vpc.terraform-eks-demo.id}"
  tags = "${
    map(
     "Name", "terraform-eks-demo-application_subnet",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "database" {
  count = "${var.subnet_count}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.1.3${count.index}.0/24"
  vpc_id            = "${aws_vpc.terraform-eks-demo.id}"
  
  tags = "${
    map(
     "Name", "terraform-eks-demo-database_subnet"
    )
  }"
}