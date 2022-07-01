provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

resource "random_pet" "name_uid" {

}

locals {
  vpc_id = "vpc-07c169fb946404dbe"
  subnet_ids = [
    "subnet-04248d77575a81093",
    "subnet-05cfcfed3b91f9791",
    "subnet-02f147ff731f8ac89"
  ]
  region = "us-east-1"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "demo-cluster-${random_pet.name_uid.id}"
  cluster_version = "1.22"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids

  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["m6i.large"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}