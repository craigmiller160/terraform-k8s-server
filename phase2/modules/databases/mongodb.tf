# TODO delete the locals
locals {
  mongodb_all_docs = split("---", file("${path.module}/k8s_yaml/mongodb.yml"))
  mongodb_configmap_doc = local.mongodb_all_docs.0
  mongodb_deployment_doc = local.mongodb_all_docs.1
  mongodb_service_doc = local.mongodb_all_docs.2
}

resource "kubernetes_config_map" "mongodb_config" {
  metadata {
    name = "mongodb-config"
    namespace = "default"
  }
  data = {
    MONGO_HOST = "mongodb-service"
    MONGO_AUTH_DB = "admin"
    MONGO_PORT = "27017"
  }
}

resource "kubernetes_manifest" "mongodb_deployment" {
  manifest = yamldecode(local.mongodb_deployment_doc)
}

resource "kubernetes_manifest" "mongodb_service" {
  manifest = yamldecode(local.mongodb_service_doc)
}