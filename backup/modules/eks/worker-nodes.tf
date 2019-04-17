########################################################################################
# Setup AutoScaling Group for worker nodes

# Setup data source to get amazon-provided AMI for EKS nodes
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.tf_eks.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # This is the AWS account that owns the image (AWS EKS team, not your own account!)
}

data "aws_region" "current" {}

# Is provided in demo code, no idea what it's used for though! TODO: DELETE
# data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encode this
# information and write it into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  tf-eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.tf_eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.tf_eks.certificate_authority.0.data}' 'demo-ca-certificate'
USERDATA
}

# create launch configuration for our ec2 nodes to use
# using userdata we setup with xtrace
resource "aws_launch_configuration" "tf_eks" {
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.instance_size}"
  name_prefix                 = "${var.cluster-name}"
  security_groups             = ["${aws_security_group.tf-eks-node.id}"]
  user_data_base64            = "${base64encode(local.tf-eks-node-userdata)}"
  key_name                    = "${var.keypair-name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tf_eks" {
  desired_capacity     = "2"
  launch_configuration = "${aws_launch_configuration.tf_eks.id}"
  max_size             = "10"
  min_size             = 1
  name                 = "terraform-eks-demo-worker-nodes"
  vpc_zone_identifier  = ["${var.app_subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "${var.cluster-name}-nodes"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}