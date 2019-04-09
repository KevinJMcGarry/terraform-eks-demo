# Call our modules while running at root level

module "network" {
  source = "./modules/network"

  // pass variables from .tfvars
  aws_region       = "${var.aws_region}"
  subnet_count     = "${var.subnet_count}"
  aws_access_key   = "${var.aws_access_key}"
  aws_secret_key   = "${var.aws_secret_key}"
}