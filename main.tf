data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.eks_auto_mode.id
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "eks" {
  description = var.cluster_name
}

resource "aws_kms_alias" "eks" {
  name          = format("alias/%s", var.cluster_name)
  target_key_id = aws_kms_key.eks.key_id
}

resource "aws_eks_cluster" "eks_auto_mode" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn                      = aws_iam_role.cluster.arn
  version                       = var.k8s_version
  bootstrap_self_managed_addons = false
  enabled_cluster_log_types     = var.enabled_cluster_log_types

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose", "system"]
    node_role_arn = aws_iam_role.node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access

    subnet_ids = [
      aws_subnet.private_subnet_az1.id,
      aws_subnet.private_subnet_az2.id,
    ]
  }

  tags = var.tags

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
  ]
}
