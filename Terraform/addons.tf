# IRSA for ALB Controller
module "alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name                              = "${var.cluster_name}-alb-irsa"
  attach_load_balancer_controller_policy = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.2"
  namespace  = "kube-system"
  create_namespace = false

  values = [yamlencode({
    clusterName = var.cluster_name
    serviceAccount = {
      create = true
      name   = "aws-load-balancer-controller"
      annotations = {
        "eks.amazonaws.com/role-arn" = module.alb_irsa.iam_role_arn
      }
    }
  })]

  depends_on = [module.eks]
}

# IRSA for Cluster Autoscaler
module "cas_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name                        = "${var.cluster_name}-cas-irsa"
  attach_cluster_autoscaler_policy = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.43.0"
  namespace  = "kube-system"

  values = [yamlencode({
    autoDiscovery = { clusterName = var.cluster_name }
    awsRegion     = var.region
    rbac = { serviceAccount = {
      create = true
      name   = "cluster-autoscaler"
      annotations = {
        "eks.amazonaws.com/role-arn" = module.cas_irsa.iam_role_arn
      }
    }}
    extraArgs = {
      balance-similar-node-groups   = "true"
      skip-nodes-with-local-storage = "false"
      expander                      = "least-waste"
    }
  })]

  depends_on = [module.eks]
}

# metrics-server
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.1"
  namespace  = "kube-system"
  values     = [yamlencode({ args = ["--kubelet-insecure-tls"] })]
  depends_on = [module.eks]
}
