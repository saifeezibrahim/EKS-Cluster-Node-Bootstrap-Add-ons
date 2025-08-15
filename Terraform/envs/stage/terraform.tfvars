region          = "ap-south-1"
cluster_name    = "stage-eks"
cluster_version = "1.29"

vpc_cidr = "10.30.0.0/16"
azs = ["ap-south-1a","ap-south-1b","ap-south-1c"]
private_subnets = ["10.30.1.0/24","10.30.2.0/24","10.30.3.0/24"]
public_subnets  = ["10.30.101.0/24","10.30.102.0/24","10.30.103.0/24"]

node_groups = {
  apps = {
    instance_types = ["m6i.large"]
    desired_size   = 3
    min_size       = 3
    max_size       = 6
    disk_size      = 80
    labels         = { role = "apps" }
    taints         = []
  }
}
