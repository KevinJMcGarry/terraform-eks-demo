variable "cluster-name" {
  type        = "string"
  description = "Name to give your EKS cluster."
}

variable "aws_region" {
    type        = "string"
    description = "Which AWS Region to use."
}

variable "aws_access_key" {
    type        = "string"
    description = "The account identification key used by your Terraform client."
}

variable "aws_secret_key" {
    type        = "string"
    description = "The secret key used by your terraform client to access AWS."
}

variable "subnet_count" {
    type        = "string"
    description = "The number of subnets we want to create per type to ensure high availability."
}

variable "instance_size" {
    type        = "string"
    description = "The size/tye of the EC2 worker node instance/s (eg m4.xlarge)."
}

variable "path_to_public_key" {
  type = "string"
  description = "path to the public key you will be using for shelling into the ec2 nodes. (eg '~/.ssh/mypubkey.pub')"
}

variable "keypair-name" {
  type = "string"
  description = "Name of the keypair declared in AWS EC2, used to connect into your instances via SSH."
}