# EKS cluster with node bootstrap and add-ons

![Terraform](https://img.shields.io/badge/Terraform-844FBA?logo=terraform&logoColor=white)
![AWS EKS](https://img.shields.io/badge/AWS_EKS-FF9900?logo=amazoneks&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?logo=ansible&logoColor=white)

Terraform builds an Amazon EKS cluster and its VPC, then installs core add-ons with Helm using **IAM Roles for Service Accounts (IRSA)**. Ansible applies an OS baseline to the worker nodes. GitHub Actions checks formatting and validates every change, and can run `terraform plan` through **GitHub OIDC**, so no AWS access keys are stored in GitHub.

This is a personal reference project, not code from an employer.

## Architecture

```
                    ┌──────────────────────── VPC (3 AZs) ─────────────────────────┐
  GitHub Actions    │  public subnets: NAT gateway, internet-facing ALBs           │
  (OIDC role) ──────┼─▶ EKS control plane (private endpoint, optional public CIDRs) │
                    │  private subnets: managed node group (AL2023)                 │
                    │     kube-system: aws-load-balancer-controller  (IRSA)         │
                    │                  cluster-autoscaler            (IRSA)         │
                    │                  metrics-server                               │
                    └───────────────────────────────────────────────────────────────┘
  Ansible (via bastion/VPN) ──▶ worker nodes: sysctl, journald, containerd mirrors, CA bundle
```

## Repository layout

| Path | Purpose |
|---|---|
| `terraform/vpc.tf` | VPC with public/private subnets, single NAT gateway, subnet tags for load balancers |
| `terraform/eks.tf` | EKS cluster and managed node groups (`terraform-aws-modules/eks` v20) |
| `terraform/addons.tf` | IRSA roles and Helm releases: AWS Load Balancer Controller, Cluster Autoscaler, metrics-server |
| `terraform/envs/{dev,stage,prod}/terraform.tfvars` | Per-environment sizing and CIDRs |
| `terraform/version.tf` | Provider versions and S3 + DynamoDB remote state |
| `ansible/inventories/<env>/aws_ec2.yml` | Dynamic inventory: finds running nodes by cluster tag |
| `ansible/roles/node_baseline` | sysctl tuning, journald limits, optional registry mirrors and enterprise CA |
| `.github/workflows/terraform.yml` | `fmt -check` + `validate` on every PR; `plan` when an OIDC role is configured |
| `Makefile` | Short commands for the steps below |

## Prerequisites

- Terraform >= 1.5, AWS CLI, kubectl, Ansible with `make ansible-deps`
- An S3 bucket and DynamoDB table for state: replace `ORG-tf-state` / `ORG-tf-locks` in `terraform/version.tf`
- Network access to the cluster API. The endpoint is **private by default**, so either run Terraform from inside the VPC, or set `endpoint_public_access_cidrs = ["<your-ip>/32"]` in the tfvars.

## Usage

```bash
make tf-validate              # offline checks, no AWS needed
make tf-init
make tf-plan ENV=dev          # selects/creates the "dev" workspace
make tf-apply ENV=dev
make kubeconfig ENV=dev
kubectl get nodes

make ansible-deps
make ansible-check ENV=dev    # dry run with diff
make ansible-apply ENV=dev

make tf-destroy ENV=dev       # tear down to stop NAT and node costs
```

To enable `plan` in CI, create an IAM role that trusts GitHub's OIDC provider for this repository and save its ARN as the repository variable `AWS_ROLE_ARN`.

## Design choices

- **IRSA, not node IAM roles.** Each add-on's service account gets its own IAM role with only the policy it needs, so a compromised pod can't use the node's permissions.
- **One codebase, per-environment tfvars and workspaces.** dev, stage and prod differ only in size and CIDRs.
- **Private API endpoint by default.** Public access is opt-in and limited to listed CIDRs.
- **No automatic apply from CI.** Plans run in CI; applies are run deliberately by a person.

## Known limitations and next steps

- Single NAT gateway keeps dev cheap but is a single point of failure; use one per AZ for prod.
- Ansible reaches nodes over SSH on private IPs, which needs a bastion or VPN. AWS SSM would remove that need.
- Next: Trivy/tfsec config scanning in CI, Karpenter as an alternative to Cluster Autoscaler, cost tags per environment.
