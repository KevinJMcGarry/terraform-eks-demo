// create local kubeconfig file from cluster info
// example command to append to current kubeconfig file --
// terraform output -module=eks eks_kubeconfig >> ~/.kube/config

output "eks_kubeconfig" {
  value = "${local.kubeconfig}"
  depends_on = [
    "aws_eks_cluster.tf_eks."
  ]
}
