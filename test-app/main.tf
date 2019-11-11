terraform {
  required_version = ">= 0.12.2"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "${var.cluster-name}-${random_string.suffix.result}"  // edited kjm
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

// added kjm
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.22.0.0/8",
    ]
  }
}

// added kjm
resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
      "10.22.0.0/16"
    ]
  }
}

// added kjm
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.22.0.0/16",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"  // pulled from github during terraform init
  version = "2.6.0"

  name                 = "${var.cluster-name}"  // added kjm
  cidr                 = "${var.cidr}"  // added kjm
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = "${var.private_subnets}"  // added kjm
  public_subnets       = "${var.public_subnets}"  // added kjm
  enable_nat_gateway   = true  // added kjm
  single_nat_gateway   = true  // added kjm - share a single nat gateway amongst all private subnets
  enable_dns_hostnames = true
  enable_dns_support   = true  // added kjm

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  // added kjm
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  // added kjm
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source       = "../modules/eks/"
  cluster_name = "${local.cluster_name}"  // added kjm
  subnets      = module.vpc.private_subnets  //edited kjm
  vpc_id       = module.vpc.vpc_id
  cluster_enabled_log_types = "${var.cluster_enabled_log_types}"  // added kjm

  // ASGs for On Demand Instances and Spot Instances - kjm
  worker_groups_launch_template = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      asg_desired_capacity = 1
      asg_max_size         = 5  // added kjm
      public_ip            = false
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]  // added kjm
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t2.medium"
      asg_desired_capacity = 1
      asg_max_size         = 5  // added kjm
      public_ip            = false
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]  // added kjm
    },
    {
      name                    = "cpu-spot-1"
      override_instance_types = ["c5.large", "c5.xlarge", "c5.2xlarge", "c5d.large"]
      spot_instance_pools     = 4
      asg_max_size            = 5
      asg_desired_capacity    = 1  // edited kjm
      kubelet_extra_args      = "--node-labels=kubernetes.io/lifecycle=spot"
      public_ip               = false
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]  // added kjm
    },
  ]
  
  //worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  //map_roles                            = var.map_roles
  //map_users                            = var.map_users
  //map_accounts                         = var.map_accounts
}
