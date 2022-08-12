locals {
  ingress_all_docs = split("---",
    file("${path.module}/k8s_yaml/ingress.yml")
  ),
  ingress_class_doc = local.ingress_all_docs.0
  ingress_deployment_doc = local.ingress_all_docs.1
}

resource "kubernetes_manifest" "ingress_class" {
  manifest = yamldecode(local.ingress_class_doc)
}

resource "kubernetes_manifest" "ingress_deployment" {
  manifest = yamldecode(local.ingress_deployment_doc)
}