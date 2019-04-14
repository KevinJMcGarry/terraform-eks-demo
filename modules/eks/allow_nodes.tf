# create config map in the eks cluster to accept nodes

########################################################################################
# setup provider for kubernetes
# NOTE - this step requires that the AWS CLI tool is configured on the computer running this terraform code
# and the cli profile must contain creds to be able to connect to the eks master
# also jq must be installed (eg brew install jq)

// using aws cli to obtain an iam token that will allow us to connect to eks master
// here we define a command as a data source

/* data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws-iam-authenticator token -i eks-demo-token | jq -r -c .status"]
} */

# create the actual masters (control plane) cluster

resource "aws_eks_cluster" "tf_eks" {
  name                      = "${var.cluster-name}"
  enabled_cluster_log_types = "${var.cluster_enabled_log_types}"
  role_arn                  = "${aws_iam_role.tf-eks-master.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.tf-eks-master.id}"]
    subnet_ids         = ["${var.app_subnet_ids}"] // application subnet ids
  }

  depends_on = [
    "aws_iam_role_policy_attachment.tf-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.tf-cluster-AmazonEKSServicePolicy",
  ]
}

// token and some other master info (endpoint address, certificate) to setup the provider to connect to kubernetes

data "aws_eks_cluster" "tf_eks" {
  name = "${var.cluster-name}"

  depends_on = ["aws_eks_cluster.tf_eks"]
}

data "aws_eks_cluster_auth" "tf_eks" {
  name = "${data.aws_eks_cluster.tf_eks.name}"
}

provider "kubernetes" {
  host                      = "${data.aws_eks_cluster.tf_eks.endpoint}"
  cluster_ca_certificate    = "${base64decode(aws_eks_cluster.tf_eks.certificate_authority.0.data)}"
  token                     = "${data.aws_eks_cluster_auth.tf_eks.token}"
  // token                     = "${data.external.aws_iam_authenticator.result.token}"
  load_config_file          = false
  // version = "~> 1.5"
}


// once connected to master, we now create/apply the config map, which allows our nodes to join/be managed by the cluster
# Allow worker nodes to join cluster via config map

/* resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
  data {
    mapRoles = <<EOF
- rolearn: ${aws_iam_role.tf-eks-node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOF
  }
  depends_on = [
    "aws_eks_cluster.tf_eks"  ] 
} */