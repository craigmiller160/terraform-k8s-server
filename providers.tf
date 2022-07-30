terraform {
  backend "kubernetes" {
    secret_suffix    = "state"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.k8s_context
}