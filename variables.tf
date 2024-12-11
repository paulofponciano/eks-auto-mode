variable "cluster_name" {
  type        = string
  description = "The name of the Kubernetes cluster."
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the resources will be deployed."
}

variable "az1" {
  type        = string
  description = "The first availability zone for the deployment."
}

variable "az2" {
  type        = string
  description = "The second availability zone for the deployment."
}

variable "k8s_version" {
  type        = string
  description = "The Kubernetes version to use for the cluster."
}

variable "endpoint_private_access" {
  type        = string
  description = "Enable or disable private access to the Kubernetes API server. Use 'true' or 'false'."
}

variable "endpoint_public_access" {
  type        = string
  description = "Enable or disable public access to the Kubernetes API server. Use 'true' or 'false'."
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "Control Plane Logging."
}

variable "istio_ingress_enabled" {
  description = "Defines whether Istio ingress will be enabled."
  type        = bool
  default     = false
}

variable "istio_nlb_ingress_internal" {
  description = "Defines whether the NLB for the Istio ingress will be internal."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM Certificate."
  type        = string
  default     = false
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
}

variable "public_subnet_az1_cidr" {
  type        = string
  description = "The CIDR block for the public subnet in the first availability zone."
}

variable "public_subnet_az2_cidr" {
  type        = string
  description = "The CIDR block for the public subnet in the second availability zone."
}

variable "private_subnet_az1_cidr" {
  type        = string
  description = "The CIDR block for the private subnet in the first availability zone."
}

variable "private_subnet_az2_cidr" {
  type        = string
  description = "The CIDR block for the private subnet in the second availability zone."
}

variable "tags" {
  type        = map(string)
  description = "AWS tags to be added to all resources created."
}
