ENV     ?= dev
TF_DIR  := terraform
ANS_DIR := ansible
TFVARS  := envs/$(ENV)/terraform.tfvars   # relative to TF_DIR (used with -chdir)

.PHONY: tf-fmt tf-init tf-validate tf-workspace tf-plan tf-apply tf-destroy kubeconfig ansible-deps ansible-check ansible-apply

tf-fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

tf-init:
	terraform -chdir=$(TF_DIR) init

tf-validate:
	terraform -chdir=$(TF_DIR) init -backend=false -input=false
	terraform -chdir=$(TF_DIR) validate

tf-workspace:
	terraform -chdir=$(TF_DIR) workspace select $(ENV) || terraform -chdir=$(TF_DIR) workspace new $(ENV)

tf-plan: tf-workspace
	terraform -chdir=$(TF_DIR) plan -var-file=$(TFVARS) -out=tfplan-$(ENV).bin

tf-apply:
	terraform -chdir=$(TF_DIR) apply tfplan-$(ENV).bin

tf-destroy: tf-workspace
	terraform -chdir=$(TF_DIR) destroy -var-file=$(TFVARS)

kubeconfig:
	aws eks update-kubeconfig --name $(ENV)-eks --region ap-south-1 --alias $(ENV)-eks

ansible-deps:
	ansible-galaxy collection install -r $(ANS_DIR)/requirements.yml

ansible-check:
	cd $(ANS_DIR) && ansible-playbook -i inventories/$(ENV)/aws_ec2.yml playbooks/node_bootstrap.yml --check --diff

ansible-apply:
	cd $(ANS_DIR) && ansible-playbook -i inventories/$(ENV)/aws_ec2.yml playbooks/node_bootstrap.yml
