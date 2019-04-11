# output of this file is defined in output.tf

# generate KUBECONFIG as output to save in ~/.kube/config locally
# save the 'terraform output eks_kubeconfig > config', run 'mv config ~/.kube/config' to use it for kubectl

// this tool also uses the local aws cli  to obtain a token to log into your cluster (like we did in worker-nodes.tf)
locals {
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.tf_eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.tf_eks.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.tf_eks.name}"
KUBECONFIG
}