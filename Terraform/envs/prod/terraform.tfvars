region          = "ap-south-1"
cluster_name    = "prod-eks"
cluster_version = "1.29"

vpc_cidr = "10.10.0.0/16"
azs = ["ap-south-1a","ap-south-1b","ap-south-1c"]
private_subnets = ["10.10.1.0/24","10.10.2.0/24","10.10.3.0/24"]
public_subnets  = ["10.10.101.0/24","10.10.102.0/24","10.10.103.0/24"]

node_groups = {
  apps = {
    instance_types = ["m6i.xlarge"]
    desired_size   = 4
    min_size       = 4
    max_size       = 10
    disk_size      = 100
    labels         = { role = "apps" }
    taints         = []
  }
}
