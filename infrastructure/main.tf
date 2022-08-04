terraform {
  backend "kubernetes" {
    secret_suffix = "infrastructure-state"
    config_path   = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.k8s_context
}

module "databases" {
  source                 = "./modules/databases"
}

module "utilities" {
  source = "./modules/utilities"
  onepassword_creds = var.onepassword_creds
  onepassword_token = var.onepassword_token
}