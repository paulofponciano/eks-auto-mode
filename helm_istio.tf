resource "helm_release" "istio_base" {
  count            = var.istio_ingress_enabled ? 1 : 0
  name             = "istio-base"
  chart            = "base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = true

  version = "1.23.0"

  depends_on = [
    aws_eks_cluster.eks_auto_mode,
  ]
}

resource "helm_release" "istiod" {
  count            = var.istio_ingress_enabled ? 1 : 0
  name             = "istio"
  chart            = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = true

  version = "1.23.0"

  depends_on = [
    aws_eks_cluster.eks_auto_mode,
    helm_release.istio_base,
  ]
}

resource "helm_release" "istio_ingress" {
  count            = var.istio_ingress_enabled ? 1 : 0
  name             = "istio-ingressgateway"
  chart            = "gateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = true

  version = "1.23.0"

  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "service.ports[0].name"
    value = "tcp-statusport"
  }

  set {
    name  = "service.ports[0].port"
    value = 15021
  }

  set {
    name  = "service.ports[0].targetPort"
    value = 15021
  }

  set {
    name  = "service.ports[0].nodePort"
    value = 30021
  }

  set {
    name  = "service.ports[0].protocol"
    value = "TCP"
  }

  set {
    name  = "service.ports[1].name"
    value = "http2"
  }

  set {
    name  = "service.ports[1].port"
    value = 80
  }

  set {
    name  = "service.ports[1].targetPort"
    value = 80
  }

  set {
    name  = "service.ports[1].nodePort"
    value = 30080
  }

  set {
    name  = "service.ports[1].protocol"
    value = "TCP"
  }

  set {
    name  = "service.ports[2].name"
    value = "https"
  }

  set {
    name  = "service.ports[2].port"
    value = 443
  }

  set {
    name  = "service.ports[2].targetPort"
    value = 443
  }

  set {
    name  = "service.ports[2].nodePort"
    value = 30443
  }

  set {
    name  = "service.ports[2].protocol"
    value = "TCP"
  }

  depends_on = [
    aws_eks_cluster.eks_auto_mode,
    helm_release.istio_base,
    helm_release.istiod,
  ]
}

resource "kubectl_manifest" "istio_target_group_binding_http" {
  count     = var.istio_ingress_enabled ? 1 : 0
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: istio-ingress
  namespace: istio-system
spec:
  serviceRef:
    name: istio-ingressgateway
    port: http2
  targetGroupARN: ${aws_lb_target_group.http[0].arn}
YAML

  depends_on = [
    aws_eks_cluster.eks_auto_mode,
    helm_release.istio_base,
    helm_release.istiod,
    helm_release.alb_ingress_controller,
    time_sleep.wait_40_seconds_albcontroller,
  ]
}

resource "kubectl_manifest" "istio_target_group_binding_https" {
  count     = var.istio_ingress_enabled ? 1 : 0
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: istio-ingress-https
  namespace: istio-system
spec:
  serviceRef:
    name: istio-ingressgateway
    port: https
  targetGroupARN: ${aws_lb_target_group.https[0].arn}
YAML

  depends_on = [
    aws_eks_cluster.eks_auto_mode,
    helm_release.istio_base,
    helm_release.istiod,
    helm_release.alb_ingress_controller,
    time_sleep.wait_40_seconds_albcontroller,
  ]
}
