resource "time_sleep" "wait_40_seconds_albcontroller" {
  count      = var.istio_ingress_enabled ? 1 : 0
  depends_on = [helm_release.alb_ingress_controller]

  create_duration = "40s"
}

resource "helm_release" "alb_ingress_controller" {
  count            = var.istio_ingress_enabled ? 1 : 0
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "kube-system"
  create_namespace = true

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller[0].arn
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = aws_vpc.cluster_vpc.id
  }

  depends_on = [
    aws_eks_cluster.eks_auto_mode,
  ]
}
