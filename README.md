# Terraform 0.12.x EKS Demo Project

**NOTE:** The current release of Terraform as of this readme is  `v0.12.13`. Please file any issues you find and note the version used.

## Use Case

This is a demo project to showcase the ease of using terraform to spin up an EKS cluster and run a simple webapp. The cluster has multiple tiers of worker nodes (on-demand and spot instances) running in private subnets. The Hello-World webapp is fronted by an ALB Ingress Controller. 

## Requirements
- python3.7 or greater, awscli, terraform 0.12.x, kubernetes cli 1.14, must be installed and located in your PATH. 
- An AWS IAM account with enough permissions to spin up the appropriate resources must be used.

## Building

- under the /test-app/terraform/ folder, edit the tfvars.example file with the appropriate values and save it as terraform.tfvars (this file should be excluded from github via .gitignore) 
**NOTE:** some default values were left in the file an example
- terraform init, plan, and apply the terraform code
- update your kubeconfig file with the new eks cluster 
- update k8s config files and kubectl apply

## Community, discussion, contribution, and support

Learn how to engage with the Kubernetes community on the [community page](http://kubernetes.io/community/).