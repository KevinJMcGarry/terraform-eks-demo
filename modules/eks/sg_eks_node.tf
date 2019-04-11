# This SG controls networking access to the Kubernetes worker nodes

resource "aws_security_group" "tf-eks-node" {
    name        = "terraform-eks-node"
    description = "Security group that applies to all nodes in the cluster"
    vpc_id      = "${var.vpc_id}"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = "${
       map(
         "Name", "terraform-eks-demo-node",
         "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}