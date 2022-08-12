terraform {
  backend "kubernetes" {
    secret_suffix = "phase3-state"
    config_path = "~/.kube/config"
  }

  required_providers {
    nexus = {
      source = "datadrivers/nexus"
      version = "1.21.0"
    }
  }
}

provider "nexus" {
  insecure = true
}