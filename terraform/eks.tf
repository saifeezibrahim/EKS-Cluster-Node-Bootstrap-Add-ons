module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name                         = var.cluster_name
  cluster_version                      = var.cluster_version
  vpc_id                               = module.vpc.vpc_id
  subnet_ids                           = module.vpc.private_subnets
  control_plane_subnet_ids             = module.vpc.private_subnets
  cluster_endpoint_public_access       = length(var.endpoint_public_access_cidrs) > 0
  cluster_endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
  cluster_endpoint_private_access      = true
  enable_irsa                          = true

  eks_managed_node_groups = {
    for name, cfg in var.node_groups :
    name => {
      instance_types = cfg.instance_types
      desired_size   = cfg.desired_size
      min_size       = cfg.min_size
      max_size       = cfg.max_size
      disk_size      = cfg.disk_size
      subnet_ids     = module.vpc.private_subnets
      labels         = cfg.labels
      taints         = cfg.taints
      ami_type       = "AL2023_x86_64_STANDARD"
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = var.cluster_name
  }
}
