// call vpc and eks modules passing in arguments
// arguments 
// https://github.com/terraform-aws-modules

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "1.60.0"  // see https://github.com/terraform-aws-modules/terraform-aws-vpc/releases for the latest version
  name               = "${var.cluster-name}"
  cidr               = "${var.cidr}"
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets    = "${var.private_subnets}"
  public_subnets     = "${var.public_subnets}"
  enable_nat_gateway = true
  single_nat_gateway = true  // share a single nat gateway amongst all private subnets
  tags               = "${merge(local.tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))}"
}

module "eks" {
  source                               = "../.."
  cluster_name                         = "${local.cluster_name}"
  subnets                              = ["${module.vpc.private_subnets}"]
  tags                                 = "${local.tags}"
  vpc_id                               = "${module.vpc.vpc_id}"
  worker_groups                        = "${local.worker_groups}"
  worker_groups_launch_template        = "${local.worker_groups_launch_template}"
  worker_group_count                   = "1"
  worker_group_launch_template_count   = "1"
  worker_additional_security_group_ids = ["${aws_security_group.all_worker_mgmt.id}"]
  map_roles                            = "${var.map_roles}"
  map_roles_count                      = "${var.map_roles_count}"
  map_users                            = "${var.map_users}"
  map_users_count                      = "${var.map_users_count}"
  map_accounts                         = "${var.map_accounts}"
  map_accounts_count                   = "${var.map_accounts_count}"
  cluster_enabled_log_types            = "${var.cluster_enabled_log_types}"
}



/* Examples -----------------------

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
  source = "../.."

  // outputs from network module
   vpc_id            = "${module.network.vpc_id}"
   app_subnet_ids    = "${module.network.app_subnet_ids}"

  // pass variables from .tfvars
  cluster-name                  = "${var.cluster-name}"
  cluster_enabled_log_types     = "${var.cluster_enabled_log_types}"
  instance_size                 = "${var.instance_size}"
  keypair-name                  = "${var.keypair-name}"
} */
