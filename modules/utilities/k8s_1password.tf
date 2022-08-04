
locals {
  onepassword_connect_all_docs = split("---", file("${path.module}/k8s_yaml/1password/1password_connect.yml"))
  onepassword_connect_configmap_doc = local.onepassword_connect_all_docs.0
  onepassword_sync_configmap_doc = local.onepassword_connect_all_docs.1
  onepassword_connect_sync_deployment_doc = local.onepassword_connect_all_docs.2
  onepassword_connect_service_doc = local.onepassword_connect_all_docs.3

  onepassword_operator_all_docs = split("---", file("${path.module}/k8s_yaml/1password/1password_operator.yml"))
  onepassword_operator_configmap_doc = local.onepassword_operator_all_docs.0
  onepassword_operator_deployment_doc = local.onepassword_operator_all_docs.1
}

resource "kubernetes_secret" "onepassword" {
  metadata {
    name = "onepassword"
  }

  data = {
    credentials = base64decode(var.onepassword_creds)
    token = var.onepassword_token
  }
}

resource "kubernetes_manifest" "onepassword_connect_config" {
  manifest = yamldecode(local.onepassword_connect_configmap_doc)
}

resource "kubernetes_manifest" "onepassword_sync_config" {
  manifest = yamldecode(local.onepassword_sync_configmap_doc)
}

# TODO maybe need TLS for this
resource "kubernetes_manifest" "onepassword_connect_sync_deployment" {
  depends_on = [kubernetes_secret.onepassword]
  manifest = yamldecode(local.onepassword_connect_sync_deployment_doc)
}

resource "kubernetes_manifest" "onepassword_connect_service" {
  manifest = yamldecode(local.onepassword_connect_service_doc)
}

resource "kubernetes_manifest" "onepassword_connect_operator_config" {
  manifest = yamldecode(local.onepassword_operator_configmap_doc)
}

resource "kubernetes_manifest" "onepassword_connect_operator_deployment" {
  manifest = yamldecode(local.onepassword_operator_deployment_doc)
}