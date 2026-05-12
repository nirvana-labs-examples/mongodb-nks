terraform {
  required_version = ">= 1.5"
  required_providers {
    nirvana = {
      source  = "nirvana-labs/nirvana"
      version = ">= 1.45"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "nirvana" {}

# The Kubernetes/Helm providers read the kubeconfig written by the NKS
# module. The file doesn't exist on the first apply — use
# `terraform apply -target=module.nks` for phase 1 so these providers
# aren't invoked.
provider "helm" {
  kubernetes {
    config_path = module.nks.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = module.nks.kubeconfig_path
}
