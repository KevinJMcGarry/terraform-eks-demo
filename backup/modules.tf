# Call our modules while running at root level

module "network" {
  source = "./modules/network"

  // pass variables from .tfvars
  cluster-name     = "${var.cluster-name}"
  aws_region       = "${var.aws_region}"
  subnet_count     = "${var.subnet_count}"
  aws_access_key   = "${var.aws_access_key}"
  aws_secret_key   = "${var.aws_secret_key}"
}

module "eks" {
  source = "./modules/eks"

  // outputs from network module
  vpc_id            = "${module.network.vpc_id}"
  app_subnet_ids    = "${module.network.app_subnet_ids}"

  // pass variables from .tfvars
  cluster-name                  = "${var.cluster-name}"
  cluster_enabled_log_types     = "${var.cluster_enabled_log_types}"
  instance_size                 = "${var.instance_size}"
  keypair-name                  = "${var.keypair-name}"
}