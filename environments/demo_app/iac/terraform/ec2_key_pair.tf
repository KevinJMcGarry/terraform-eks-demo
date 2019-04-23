# create the ec2 Key Pair in AWS using the local public key

resource "aws_key_pair" "mykeypair" {
  key_name = "aws_terraform_eks_demo"
  public_key = "${file("${var.path_to_public_key}")}"
}