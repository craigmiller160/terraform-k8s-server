terraform {
  backend "kubernetes" {
    secret_suffix = "phase2-state"
    config_path   = "~/.kube/config"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.k8s_context
}

module "databases" {
  source = "./modules/databases"
}

module "utilities" {
  source            = "./modules/utilities"
  onepassword_creds = var.onepassword_creds
  onepassword_token = var.onepassword_token
  nexus_image       = var.nexus_image
}