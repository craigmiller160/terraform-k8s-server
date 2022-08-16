# This is a manifest because of a bug in the k8s provider for the service account resource
resource "kubernetes_manifest" "onepassword_connect_operator_service_account" {
  manifest = yamldecode(file("${path.module}/k8s_yaml/1Password_service_account.yml"))
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
  rule {
    api_groups = ["apps"]
    resources = [
      "deployments",
      "daemonsets",
      "replicasets",
      "statefulsets"
    ]
    verbs = [
      "create",
      "delete",
      "get",
      "list",
      "patch",
      "update",
      "watch"
    ]
  }
  rule {
    api_groups = ["monitoring.coreos.com"]
    resources = ["        servicemonitors"]
    verbs = ["get", "create"]
  }
  rule {
    api_groups = ["apps"]
    resource_names = ["onepassword-connect-operator"]
    resources = ["deployments/finalizers"]
    verbs = ["        update"]
  }
  rule {
    api_groups = [""]
    resources = ["pods"]
    verbs = ["get"]
  }
  rule {
    api_groups = ["apps"]
    resources = [
      "replicasets",
      "deployments"
    ]
    verbs = ["get"]
  }
  rule {
    api_groups = ["onepassword.com"]
    resources = ["*"]
    verbs = [
      "create",
      "delete",
      "get",
      "list",
      "patch",
      "update",
      "watch"
    ]
  }
}