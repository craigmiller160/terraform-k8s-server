locals {
  nexus_all_docs = split("---",
    replace(file("${path.module}/k8s_yaml/nexus.yml"), "%NEXUS_IMAGE%", "klo2k/nexus3:3.29.2-02")
  )
  nexus_deployment_doc = local.nexus_all_docs.0
  nexus_service_doc = local.nexus_all_docs.1
}

resource "kubernetes_manifest" "nexus_deployment" {
  manifest = yamldecode(local.nexus_deployment_doc)
}

resource "kubernetes_manifest" "nexus_service" {
  manifest = yamldecode(local.nexus_service_doc)
}