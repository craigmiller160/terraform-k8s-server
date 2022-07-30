terraform {
  backend "kubernetes" {
    secret_suffix  = "state"
    config_path    = "~/.kube/config"
    # TODO figuring this out
    config_context = "kind"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.k8s_context
}