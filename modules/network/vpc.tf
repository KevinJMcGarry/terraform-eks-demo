resource "aws_vpc" "terraform-eks-demo" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = "${
    map(
     "Name", "terraform-eks",
     "kubernetes.io/cluster/terraform-eks-demo", "shared",
    )
  }"
}
