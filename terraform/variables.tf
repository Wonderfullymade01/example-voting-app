variable "region" {
  description = "AWS region to build in (our account only allows eu-north-1)"
  type        = string
  default     = "eu-north-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "voting-app"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.36"
}

variable "node_instance_type" {
  description = "EC2 size for the worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_count" {
  description = "How many worker nodes to run"
  type        = number
  default     = 2
}
