terraform {
  required_version = ">= 0.11.8"
}

provider "aws" {
  //access_key = "${var.aws_access_key}"
  //secret_key = "${var.aws_secret_key}"
  version = ">= 2.8.0"
  region  = "${var.region}"
}

provider "random" {
  version = "= 1.3.1"
}

data "aws_availability_zones" "available" {}

locals {
  //cluster_name = "test-eks-${random_string.suffix.result}"
  cluster_name = "${var.cluster-name}"

  # the commented out worker group list below shows an example of how to define
  # multiple worker groups of differing configurations
  # worker_groups = [
  #   {
  #     asg_desired_capacity = 2
  #     asg_max_size = 10
  #     asg_min_size = 2
  #     instance_type = "m4.xlarge"
  #     name = "worker_group_a"
  #     additional_userdata = "echo foo bar"
  #     subnets = "${join(",", module.vpc.private_subnets)}"
  #   },
  #   {
  #     asg_desired_capacity = 1
  #     asg_max_size = 5
  #     asg_min_size = 1
  #     instance_type = "m4.2xlarge"
  #     name = "worker_group_b"
  #     additional_userdata = "echo foo bar"
  #     subnets = "${join(",", module.vpc.private_subnets)}"
  #   },
  # ]


  # the commented out worker group tags below shows an example of how to define
  # custom tags for the worker groups ASG
  # worker_group_tags = {
  #   worker_group_a = [
  #     {
  #       key                 = "k8s.io/cluster-autoscaler/node-template/taint/nvidia.com/gpu"
  #       value               = "gpu:NoSchedule"
  #       propagate_at_launch = true
  #     },
  #   ],
  #   worker_group_b = [
  #     {
  #       key                 = "k8s.io/cluster-autoscaler/node-template/taint/nvidia.com/gpu"
  #       value               = "gpu:NoSchedule"
  #       propagate_at_launch = true
  #     },
  #   ],
  # }

  worker_groups = [
    {
      # This will launch an autoscaling group with only On-Demand instances
      instance_type        = "t3.medium"
      name                 = "onDemand_Group_A"
      additional_userdata  = "echo something in here"
      subnets              = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = 3
      asg_max_size         = 10
      asg_min_size         = 3
    },
    {
      # This will launch another autoscaling group with only On-Demand instances
      // see module eks worker_group_count, this number must align with number of worker_groups you define
      instance_type        = "c5.large"
      name                 = "onDemand_Group_B"
      additional_userdata  = "echo something in here"
      subnets              = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = 1
      asg_max_size         = 10
      asg_min_size         = 1
    },
  ]

  worker_groups_launch_template = [
    {
      # This will launch an autoscaling group with only Spot Fleet instances
      instance_type                            = "t2.small"
      name                                     = "SpotFleet_Group_A"
      additional_userdata                      = "echo something in here"
      subnets                                  = "${join(",", module.vpc.private_subnets)}"
      additional_security_group_ids            = "${aws_security_group.worker_group_mgmt_one.id},${aws_security_group.worker_group_mgmt_two.id}"
      override_instance_type                   = "t3.small"
      asg_desired_capacity                     = 0 // set to 0 to disable launching of spot fleet
      asg_max_size                             = 0 // set to 0 to disable launching of spot fleet
      asg_min_size                             = 0 // set to 0 to disable launching of spot fleet
      spot_instance_pools                      = 10
      on_demand_percentage_above_base_capacity = "0"
    },
  ]
  tags = {
    Environment = "Demo"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
    Workspace   = "${terraform.workspace}"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  description = "SG to be applied to all *nix machines"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}