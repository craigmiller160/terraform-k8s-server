locals {
  all_service_account_docs = split("---", file("${path.module}/k8s_yaml/1password_provided/1password_service_account.yml"))
  service_account_doc = local.all_service_account_docs.0
  cluster_role_binding_doc = local.all_service_account_docs.1
  cluster_role_doc = local.all_service_account_docs.2
}

resource "kubernetes_manifest" "onepassword_provided_item" {
  manifest = yamldecode(file("${path.module}/k8s_yaml/1password_provided/1password_item.yml"))
}

resource "kubernetes_manifest" "onepassword_provided_service_account" {
  manifest = yamldecode(local.service_account_doc)
}

resource "kubernetes_manifest" "onepassword_provided_cluster_role_binding" {
  manifest = yamldecode(local.cluster_role_binding_doc)
}

resource "kubernetes_manifest" "onepassword_provided_cluster_role" {
  manifest = yamldecode(local.cluster_role_doc)
}