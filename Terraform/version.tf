terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws         = { source = "hashicorp/aws", version = "~> 5.50" }
    helm        = { source = "hashicorp/helm", version = "~> 2.13" }
    kubernetes  = { source = "hashicorp/kubernetes", version = "~> 2.29" }
  }
  backend "s3" {
    bucket         = "ORG-tf-state"
    key            = "eks/platform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "ORG-tf-locks"
    encrypt        = true
  }
}
