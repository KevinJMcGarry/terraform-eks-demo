# output vpc_id to be used in the security module
output "vpc_id" {
  value = "${aws_vpc.terraform-eks-demo.id}"
}

output "app_subnet_ids" {
  value = "${aws_subnet.application.*.id}"
}