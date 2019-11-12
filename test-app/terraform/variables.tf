variable "region" {
  default = "us-east-2"
}

// everything below this line added by kjm to make code more dynamic
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

variable "cluster-name" {
  type        = "string"
  description = "Name to give your EKS cluster."
}