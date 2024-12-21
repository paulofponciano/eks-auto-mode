# resource "kubectl_manifest" "karpenter-nodeclass-custom-spot" {
#   yaml_body = <<YAML
# apiVersion: eks.amazonaws.com/v1
# kind: NodeClass
# metadata:
#   name: ${var.cluster_name}-general-purpose-spot
# spec:
#   subnetSelectorTerms:
#     - tags:
#         karpenter.sh/discovery: "true"
#   securityGroupSelectorTerms:
#     - tags:
#         aws:eks:cluster-name: ${var.cluster_name}
#   role: ${aws_iam_role.node.name}
#   blockDeviceMappings:
#     - deviceName: /dev/xvda
#       ebs:
#         volumeSize: 20Gi
#         volumeType: gp3
#         iops: 3000
#         deleteOnTermination: true
#         throughput: 125
# YAML

#   depends_on = [
#     aws_eks_cluster.eks_auto_mode,
#   ]
# }

resource "kubectl_manifest" "karpenter-nodepool-custom-spot" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: ${var.cluster_name}-general-purpose-spot
  labels:
    capacity-type: spot
spec:
  template:
    metadata:
      labels:
        capacity-type: spot
    spec:
      requirements:
        - key: eks.amazonaws.com/instance-category
          operator: In
          values: ["c", "m", "r"]
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: eks.amazonaws.com/instance-generation
          operator: Gt
          values: ["4"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
        - key: topology.kubernetes.io/zone
          operator: In
          values: [${var.az1}, ${var.az2}]
      nodeClassRef:
        group: eks.amazonaws.com
        kind: NodeClass
        name: default
      taints:
        - key: "general-purpose-spot"
          effect: NoSchedule
  limits:
    cpu: 50
    memory: 100Gi
YAML

  depends_on = [
    aws_eks_cluster.eks_auto_mode,
  ]
}