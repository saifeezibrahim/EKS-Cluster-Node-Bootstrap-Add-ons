# terraform-ansible-multi-env

![Terraform](https://img.shields.io/badge/Terraform-HCL-blue?logo=terraform)
![Ansible](https://img.shields.io/badge/Ansible-Automation-yellow?logo=ansible)

## Overview

**terraform-ansible-multi-env** is a public repository designed to streamline infrastructure provisioning and configuration management using both [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/). It provides a modular approach to managing multiple environments (e.g., dev, staging, prod) efficiently.

## Features

- **Multi-Environment Support**: Easily manage and switch between different infrastructure environments.
- **Infrastructure as Code**: Define cloud resources using Terraform modules.
- **Configuration Management**: Automate software installation and configuration with Ansible playbooks.
- **Modular Structure**: Easily extend and customize modules for your needs.
- **Open Source**: Free to use, modify, and contribute.

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed locally
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed locally
- Access to your cloud provider (e.g., AWS, Azure, GCP)
- SSH access configured for Ansible remote management

### Clone the Repository

```bash
git clone https://github.com/saifeezibrahim/terraform-ansible-multi-env.git
cd terraform-ansible-multi-env
```

### Usage

1. **Configure Environment Variables**

   Set up your environment variables for authentication and configuration in `.env` files or via your shell.

2. **Terraform: Provision Infrastructure**

   ```bash
   cd terraform/
   terraform init
   terraform plan -var-file=env/dev.tfvars
   terraform apply -var-file=env/dev.tfvars
   ```

3. **Ansible: Configure Servers**

   ```bash
   cd ansible/
   ansible-playbook -i inventories/dev/hosts playbook.yml
   ```

### Directory Structure

```
terraform-ansible-multi-env/
├── ansible/
│   ├── inventories/
│   └── playbook.yml
├── terraform/
│   ├── modules/
│   ├── env/
│   └── main.tf
└── README.md
```

## Customization

- Add more Terraform modules for new resource types.
- Extend Ansible playbooks for your application stack.
- Create new environment variable files in `terraform/env/`.

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements.

## License

This repository currently does not specify a license. Please add a license file for open source compliance.

## Author

- [saifeezibrahim](https://github.com/saifeezibrahim)

---

*This repository is actively maintained. For questions or support, open an issue or contact the author via GitHub.*
