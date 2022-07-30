terraform {
  backend "kubernetes" {
    secret_suffix  = "state"
    config_context = var.k8s_context
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.k8s_context
}