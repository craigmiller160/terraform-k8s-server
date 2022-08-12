terraform {
  backend "kubernetes" {
    secret_suffix = "phase3-state"
    config_path   = "~/.kube/config"
  }

  required_providers {
    nexus = {
      source  = "datadrivers/nexus"
      version = "1.21.0"
    }
  }
}

provider "nexus" {
  insecure = true
  password = var.nexus_admin_password
  username = "admin"
  # TODO need to make this work with https/other host for prod
  url = "http://127.0.0.1:30003"
}