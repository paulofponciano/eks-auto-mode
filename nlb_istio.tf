resource "aws_lb" "istio_ingress" {
  count                            = var.istio_ingress_enabled ? 1 : 0
  name                             = join("-", [var.cluster_name, "istio-ingress"])
  internal                         = var.istio_nlb_ingress_internal
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true

  subnets = [
    aws_subnet.public_subnet_az1.id,
    aws_subnet.public_subnet_az2.id,
  ]

  tags = merge(
    var.tags,
    {
      Name                                        = join("-", [var.cluster_name, "istio-ingress"]),
      "kubernetes.io/cluster/${var.cluster_name}" = "shared",
    }
  )
}

resource "aws_lb_target_group" "http" {
  count             = var.istio_ingress_enabled ? 1 : 0
  name              = format("%s-http", var.cluster_name)
  port              = 30080
  protocol          = "TCP"
  vpc_id            = aws_vpc.cluster_vpc.id
  proxy_protocol_v2 = false
}

resource "aws_lb_target_group" "https" {
  count             = var.istio_ingress_enabled ? 1 : 0
  name              = format("%s-https", var.cluster_name)
  port              = 30443
  protocol          = "TCP"
  vpc_id            = aws_vpc.cluster_vpc.id
  proxy_protocol_v2 = false
}

resource "aws_lb_listener" "ingress_443" {
  count             = var.istio_ingress_enabled ? 1 : 0
  load_balancer_arn = aws_lb.istio_ingress[0].arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = "CERTIFICATE_ARN"
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https[0].arn
  }
}

resource "aws_lb_listener" "ingress_80" {
  count             = var.istio_ingress_enabled ? 1 : 0
  load_balancer_arn = aws_lb.istio_ingress[0].arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http[0].arn
  }
}
