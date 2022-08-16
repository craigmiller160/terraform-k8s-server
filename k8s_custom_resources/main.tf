terraform {
  backend "kubernetes" {
    secret_suffix = "k8s-custom-resources-state"
    config_path   = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.k8s_context
}