terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.34.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.17.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks_auto_mode.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_auto_mode.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_auto_mode.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_auto_mode.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.default.token
}

provider "kubectl" {
  host                   = aws_eks_cluster.eks_auto_mode.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_auto_mode.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.default.token
}
