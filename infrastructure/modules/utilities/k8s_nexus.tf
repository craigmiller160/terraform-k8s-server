locals {
  nexus_all_docs = split("---",
    replace(file("${path.module}/k8s_yaml/nexus.yml"), "%NEXUS_IMAGE%", var.nexus_image)
  )
  nexus_config_doc = local.nexus_all_docs.0
  nexus_deployment_doc = local.nexus_all_docs.1
  nexus_service_doc = local.nexus_all_docs.2
}

resource "kubernetes_manifest" "nexus_config" {
  manifest = yamldecode(local.nexus_config_doc)
}

resource "kubernetes_manifest" "nexus_deployment" {
  manifest = yamldecode(local.nexus_deployment_doc)
}

resource "kubernetes_manifest" "nexus_service" {
  manifest = yamldecode(local.nexus_service_doc)
}