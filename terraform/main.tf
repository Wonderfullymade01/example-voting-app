# --- Look up the default VPC and its subnets (we use these, we don't create a new network) ---

data "aws_vpc" "default" {
  default = true
}

# The default subnets: one in each availability zone (eu-north-1a, 1b, 1c)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# --- The EKS cluster, built with the community EKS module ---

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Keep the cluster's control-plane logs for 7 days (default is 90) to keep costs down
  cloudwatch_log_group_retention_in_days = 7

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # Let kubectl on your laptop (and later GitHub Actions) reach the cluster over the internet
  endpoint_public_access = true

  # Make the IAM user running terraform (capstone-admin) an admin of the cluster
  enable_cluster_creator_admin_permissions = true

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  # Core add-ons every cluster needs: DNS, pod networking, service routing
  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
  }

  # Worker nodes: the EC2 machines where your containers actually run
  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.node_instance_type]

      min_size     = var.node_count
      max_size     = var.node_count + 1
      desired_size = var.node_count
    }
  }
}
