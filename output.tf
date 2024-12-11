output "cluster_name" {
  value = aws_eks_cluster.eks_auto_mode.name
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
