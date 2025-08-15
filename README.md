# EKS Platform Stack (Terraform + Helm + optional Ansible)

Provision an AWS EKS cluster with Terraform, install core add-ons via Helm, and optionally apply node baseline via Ansible.

## Prereqs
- Terraform >= 1.5
- AWS CLI v2
- kubectl, helm
- Ansible >= 2.14 (optional)
- Remote state S3 bucket + DynamoDB table created

## Quickstart (dev)
make tf-init ENV=dev
make tf-plan ENV=dev
make tf-apply ENV=dev
aws eks update-kubeconfig --name dev-eks --region ap-south-1 --alias dev-eks
kubectl get nodes -o wide

Optional Ansible node bootstrap:
make ansible-check ENV=dev
make ansible-apply ENV=dev

## Notes
- IRSA is used for controllers (no static cloud keys).
- Keep business workloads out of Terraform; use GitOps for apps.

## How to use
	•	Initialize and plan:
	•	make tf-init ENV=dev
	•	make tf-plan ENV=dev
	•	make tf-apply ENV=dev
	•	make kubeconfig ENV=dev
	•	Validate cluster:
	•	kubectl get nodes -A
	•	Install add-ons happen as part of Terraform apply.
	•	Optional Ansible:
	•	make ansible-check ENV=dev
	•	make ansible-apply ENV=dev
