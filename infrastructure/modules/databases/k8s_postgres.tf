locals {
  postgres_all_docs = split("---", file("${path.module}/k8s_yaml/postgres.yml"))
  postgres_deployment_doc = local.postgres_all_docs.0
  postgres_service_doc = local.postgres_all_docs.1
}

resource "kubernetes_manifest" "postgres_deployment" {
  manifest = yamldecode(local.postgres_deployment_doc)
}

resource "kubernetes_manifest" "postgres_service" {
  manifest = yamldecode(local.postgres_service_doc)
}