# This SG controls networking access to the EKS Master nodes

resource "aws_security_group" "tf-eks-master" {
    name        = "terraform-eks-cluster"
    description = "Cluster communication with worker nodes. Allow access to k8s Masters"
    vpc_id      = "${var.vpc_id}"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags {
        Name = "${var.cluster-name}"
    }
}