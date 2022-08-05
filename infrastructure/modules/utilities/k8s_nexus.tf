locals {
  nexus_all_docs = split("---",
    replace(file("${path.module}/k8s_yaml/nexus.yml"), "%NEXUS_IMAGE%", var.nexus_image)
  )
  nexus_deployment_doc = local.nexus_all_docs.0
  nexus_service_doc = local.nexus_all_docs.1
}

resource "docker_registry_image" "extended_busybox" {
  name = "localhost:5000/extended-busybox:1.1"
  build {
    context = "${path.module}/docker"
    dockerfile = "ExtendedBusyBox_Dockerfile"
  }
}

resource "kubernetes_manifest" "nexus_deployment" {
  depends_on = [docker_registry_image.extended_busybox]
  manifest = yamldecode(local.nexus_deployment_doc)
}

resource "kubernetes_manifest" "nexus_service" {
  manifest = yamldecode(local.nexus_service_doc)
}