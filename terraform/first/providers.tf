#terraform aws requierment
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }

        kubernetes = {
            source = "hashicorp/kubernetes"
            version = ">= 2.0"
        }

        helm = {
            source = "hashicorp/helm"
            version = "~> 2.0"
        }
    }
}


# aws terraform provider
provider "aws" {
    region = "${var.region}"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}