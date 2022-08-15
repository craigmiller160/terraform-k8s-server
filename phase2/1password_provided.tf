locals {
  all_service_account_docs = split("---", file("${path.module}/k8s_yaml/1password_provided/1password_service_account.yml"))
  service_account_doc = local.all_service_account_docs.0
  cluster_role_binding_doc = local.all_service_account_docs.1
  cluster_role_doc = local.all_service_account_docs.2
}

resource "kubernetes_service_account" "onepassword_connect_operator_service_account" {
  metadata {
    name = "onepassword-connect-operator"
    namespace = "default"
  }
}

resource "kubernetes_cluster_role_binding" "onepassword_connect_operator_cluster_role_binding" {
  metadata {
    name = "onepassword-connect-operator-default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "onepassword-connect-operator"
  }
  subject {
    kind = "ServiceAccount"
    name = "onepassword-connect-operator"
    namespace = "default"
  }
}

resource "kubernetes_cluster_role" "onepassword_connect_operator_cluster_role" {
  metadata {
    name = "onepassword-connect-operator"
  }
  rule {
    api_groups = [""]
    verbs = [
      "create",
      "delete",
      "get",
      "list",
      "patch",
      "update",
      "watch"
    ]
    resources = [
      "pods",
      "services",
      "services/finalizers",
      "endpoints",
      "persistentvolumeclaims",
      "events",
      "configmaps",
      "secrets",
      "namespaces"
    ]
  }
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