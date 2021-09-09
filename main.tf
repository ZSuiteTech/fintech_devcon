terraform {
  required_version = ">= 0.12.6"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.4.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.11.3"
    }
  }

  backend "s3" {
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "random" {
}

resource "random_string" "suffix" {
  length  = 3
  special = false
}

locals {
  tags = {
    Environment = "demo"
  }
  cluster_name = "zsuite-devcon-${random_string.suffix.result}"
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "zsuite-devcon-vpc${var.vpc_suffix == "" ? "" : "-${var.vpc_suffix}"}"
  cidr                 = "192.168.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["192.168.160.0/19","192.168.96.0/19","192.168.128.0/19"]
  public_subnets       = ["192.168.64.0/19","192.168.0.0/19","192.168.32.0/19"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  # k8s coredns service deploys with ec2 compute-type
  # had to change manually
  # this needs to be scripted
  # eks.amazonaws.com/compute-type: fargate
  enable_dns_support = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.1.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  # creates oidc provider
  enable_irsa     = true

  tags = local.tags

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.small"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t3.small"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
}

/* Step 3
module "argocd" {
  source = "./argocd"
  cluster_id = module.eks.cluster_id
}
*/

/* Step 5
module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.4.0"
  aws_alb_ingress_controller_version = "1.1.8"

  aws_region_name  = var.aws_region
  aws_vpc_id = module.vpc.vpc_id
  k8s_cluster_name = local.cluster_name
  
  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"  
}
*/

