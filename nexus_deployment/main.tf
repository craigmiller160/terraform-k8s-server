terraform {
  backend "kubernetes" {
    secret_suffix = "nexus-deployment-state"
    config_path   = "~/.kube/config"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
    onepassword = {
      source = "1Password/onepassword"
      version = "1.1.4"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.k8s_context
}

provider "onepassword" {

}