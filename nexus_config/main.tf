terraform {
  backend "kubernetes" {
    secret_suffix = "nexus-config-state"
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
  url = join("", ["https://", var.nexus_host])
}