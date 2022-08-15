
locals {
  onepassword_connect_all_docs = split("---", file("${path.module}/k8s_yaml/1password_connect.yml"))
  onepassword_connect_configmap_doc = local.onepassword_connect_all_docs.0
  onepassword_sync_configmap_doc = local.onepassword_connect_all_docs.1
  onepassword_connect_sync_deployment_doc = local.onepassword_connect_all_docs.2
  onepassword_connect_service_doc = local.onepassword_connect_all_docs.3

  onepassword_operator_all_docs = split("---", file("${path.module}/k8s_yaml/1password_operator.yml"))
  onepassword_operator_configmap_doc = local.onepassword_operator_all_docs.0
  onepassword_operator_deployment_doc = local.onepassword_operator_all_docs.1

  onepassword_secret_values_all_docs = split("---", file("${path.module}/k8s_yaml/1password_secret_values.yml"))
  onepassword_secret_values_mongodb_root_account_doc = local.onepassword_secret_values_all_docs.0
  onepassword_secret_values_postgres_root_account_doc = local.onepassword_secret_values_all_docs.1
  onepassword_secret_values_database_tls_doc = local.onepassword_secret_values_all_docs.2
  onepassword_secret_values_craigmiller160_tls_doc = local.onepassword_secret_values_all_docs.3
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
  depends_on = [
    kubernetes_manifest.onepassword_connect_sync_deployment,
    kubernetes_manifest.onepassword_connect_service,
    kubernetes_service_account.onepassword_connect_operator_service_account,
    kubernetes_cluster_role_binding.onepassword_connect_operator_cluster_role_binding,
    kubernetes_cluster_role.onepassword_connect_operator_cluster_role
  ]
  manifest = yamldecode(local.onepassword_operator_deployment_doc)
}

resource "kubernetes_manifest" "secret_mongodb_root_account" {
  depends_on = [kubernetes_manifest.onepassword_connect_operator_deployment]
  manifest = yamldecode(local.onepassword_secret_values_mongodb_root_account_doc)
}

resource "kubernetes_manifest" "secret_postgres_root_account" {
  depends_on = [kubernetes_manifest.onepassword_connect_operator_deployment]
  manifest = yamldecode(local.onepassword_secret_values_postgres_root_account_doc)
}

resource "kubernetes_manifest" "secret_database_tls_certs" {
  depends_on = [kubernetes_manifest.onepassword_connect_operator_deployment]
  manifest = yamldecode(local.onepassword_secret_values_database_tls_doc)
}

resource "kubernetes_manifest" "secret_craigmiller160_tls_certs" {
  depends_on = [kubernetes_manifest.onepassword_connect_operator_deployment]
  manifest = yamldecode(local.onepassword_secret_values_craigmiller160_tls_doc)
}