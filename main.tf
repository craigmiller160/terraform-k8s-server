terraform {
  backend "kubernetes" {
    secret_suffix = "state"
    config_path   = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.k8s_context
}

module "databases" {
  source                 = "./modules/databases"
  postgres_root_password = var.postgres_root_password
  mongodb_root_password  = var.mongodb_root_password
  database_cert          = var.database_cert
  database_key           = var.database_key
}

module "utilities" {
  source = "./modules/utilities"
  onepassword_creds = var.onepassword_creds
  onepassword_token = var.onepassword_token
}