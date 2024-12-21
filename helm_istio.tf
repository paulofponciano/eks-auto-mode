resource "helm_release" "istio_base" {
  count            = var.istio_ingress_enabled ? 1 : 0
  name             = "istio-base"
  chart            = "base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = true

  version = var.istio_version

  depends_on = [
    aws_eks_cluster.eks_auto_mode,
  ]
}

resource "time_sleep" "wait_60_warmup_first_node" {
  count      = var.istio_ingress_enabled ? 1 : 0
  depends_on = [helm_release.istio_base]

  create_duration = "60s"
}

resource "helm_release" "istiod" {
  count            = var.istio_ingress_enabled ? 1 : 0
  name             = "istio"
  chart            = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = true

  version = var.istio_version

  depends_on = [
    aws_eks_cluster.eks_auto_mode,
    helm_release.istio_base,
    time_sleep.wait_60_warmup_first_node
  ]
}

resource "helm_release" "istio_ingress" {
  count            = var.istio_ingress_enabled ? 1 : 0
  name             = "istio-ingressgateway"
  chart            = "gateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = true
  version          = var.istio_version

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = var.certificate_arn
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
    value = "${aws_subnet.public_subnet_az1.id}\\,${aws_subnet.public_subnet_az2.id}"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = var.istio_nlb_ingress_scheme
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-attributes"
    value = "load_balancing.cross_zone.enabled=true"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "tcp"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"
    value = "https"
  }

  depends_on = [
    aws_eks_cluster.eks_auto_mode,
    helm_release.istio_base,
    helm_release.istiod,
    time_sleep.wait_60_warmup_first_node
  ]
}
