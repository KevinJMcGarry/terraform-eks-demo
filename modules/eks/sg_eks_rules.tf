# Setup worker node security group
resource "aws_security_group_rule" "tf-eks-node-ingress-self" {
  description              = "Allow eks demo nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.tf-eks-node.id}"
  source_security_group_id = "${aws_security_group.tf-eks-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "tf-eks-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.tf-eks-node.id}"
  source_security_group_id = "${aws_security_group.tf-eks-master.id}"
  to_port                  = 65535
  type                     = "ingress"
}

# Allow worker nodes access to EKS master cluster
resource "aws_security_group_rule" "tf-eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.tf-eks-master.id}"
  source_security_group_id = "${aws_security_group.tf-eks-node.id}"
  to_port                  = 443
  type                     = "ingress"
}
