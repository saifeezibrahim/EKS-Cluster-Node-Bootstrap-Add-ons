ENV ?= dev
TF_DIR := terraform
ANS_DIR := ansible

tf-init:
	terraform -chdir=$(TF_DIR) init

tf-workspace:
	terraform -chdir=$(TF_DIR) workspace select $(ENV) || terraform -chdir=$(TF_DIR) workspace new $(ENV)

tf-plan: tf-workspace
	terraform -chdir=$(TF_DIR) validate
	terraform -chdir=$(TF_DIR) plan -var-file=$(TF_DIR)/envs/$(ENV)/terraform.tfvars -out=$(TF_DIR)/tfplan-$(ENV).bin

tf-apply:
	terraform -chdir=$(TF_DIR) apply $(TF_DIR)/tfplan-$(ENV).bin

tf-destroy:
	terraform -chdir=$(TF_DIR) destroy -var-file=$(TF_DIR)/envs/$(ENV)/terraform.tfvars

kubeconfig:
	aws eks update-kubeconfig --name $(ENV)-eks --region ap-south-1 --alias $(ENV)-eks

ansible-check:
	cd $(ANS_DIR) && ansible-playbook -i inventories/$(ENV)/aws_ec2.yml playbooks/node_bootstrap.yml --check --diff --limit eks_nodes

ansible-apply:
	cd $(ANS_DIR) && ansible-playbook -i inventories/$(ENV)/aws_ec2.yml playbooks/node_bootstrap.yml --limit eks_nodes
