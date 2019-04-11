variable "cluster-name" {
  type        = "string"
  description = "Name to give your EKS cluster."
}

variable "vpc_id" {
  type = "string"
  description = "ID of the VPC used to setup the cluster."
}

variable "instance_type" {
  type = "string"
  description = "Type/Size of the ec2 instance/s (eg m4.xlarge etc)."
}

variable "keypair-name" {
  type = "string"
  description = "Name of the keypair declared in AWS EC2, used to connect into your instances via SSH."
}

variable "app_subnet_ids" {
  type = "list"
}