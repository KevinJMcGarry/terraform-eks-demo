# This is used to output an IAM Role authentication ConfigMap from your Terraform configuration
# Run terraform output config_map_aws_auth and save the configuration into a file, e.g. config_map_aws_auth.yaml
# terraform output -module=eks config_map_aws_auth >> ~/tempdir/config_map_aws_auth.yaml
# Finally run kubectl apply -f config_map_aws_auth.yaml and then kubectl get nodes --watch

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.tf-eks-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}