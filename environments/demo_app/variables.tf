variable "cluster-name" {
  type        = "string"
  description = "Name to give your EKS cluster."
}

variable "region" {
  default = "us-west-2"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = "list"

  default = []
}

variable "map_accounts_count" {
  description = "The count of accounts in the map_accounts list."
  type        = "string"
  default     = 1
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type        = "list"

  default = [
    {
      role_arn = "arn:aws:iam::148069999550:role/EKS_Demo_Role"
      username = "EKS_Demo_Role"
      group    = "system:masters"
    },
  ]
}

variable "map_roles_count" {
  description = "The count of roles in the map_roles list."
  type        = "string"
  default     = 1
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type        = "list"

  default = [
    {
      user_arn = "arn:aws:iam::148069999550:user/Kevinm"
      username = "Kevinm"
      group    = "system:masters"
    },
    {
      user_arn = "arn:aws:iam::148069999550:user/andrewc"
      username = "andrewc"
      group    = "system:masters"
    },
  ]
}

variable "map_users_count" {
  description = "The count of roles in the map_users list."
  type        = "string"
  default     = 2
}

variable "cluster_enabled_log_types" {
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = "list"
}

variable "public_subnets" {
  default     = []
  description = "A list of the subnets that will be attached to an IGW"
  type        = "list"
}

variable "private_subnets" {
  default     = []
  description = "A list of the subnets that will be attached to one or more Nat Gateways. This is where the EKS worker nodes will reside"
  type        = "list"
}

variable "cidr" {
  description = "The VPC CIDR to use (eg 10.1.0.0/16)"
  type        = "string"
}

/* variable "aws_access_key" {
    type        = "string"
    description = "The account identification key used by your Terraform client."
}

variable "aws_secret_key" {
    type        = "string"
    description = "The secret key used by your terraform client to access AWS."
} */