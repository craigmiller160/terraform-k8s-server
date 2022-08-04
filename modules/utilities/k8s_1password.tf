
locals {
  onepassword_connect_all_docs = split("---", file("${path.module}/k8s_yaml/1password/1password_connect.yml"))
  onepassword_connect_configmap_doc = local.onepassword_connect_all_docs.0
  onepassword_sync_configmap_doc = local.onepassword_connect_all_docs.1
  onepassword_connect_sync_deployment_doc = local.onepassword_connect_all_docs.2
  onepassword_connect_service_doc = local.onepassword_connect_all_docs.3
}

resource "kubernetes_secret" "onepassword" {
  metadata {
    name = "1password"
  }

  data = {
    credentials = base64decode(var.onepassword_creds)
    token = var.onepassword_token
  }
}

resource "kubernetes_manifest" "onepassword_connect_configmap" {
  manifest = yamldecode(local.onepassword_connect_configmap_doc)
}

resource "kubernetes_manifest" "onepassword_sync_configmap" {
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

resource "kubernetes_config_map" "onepassword_operator" {
  metadata {
    name = "onepassword-operator"
  }
  data = {
    WATCH_NAMESPACE = "default"
    OPERATOR_NAME = "onepassword-operator"
    OP_CONNECT_HOST = "http://onepassword-service:8081"
    POLLING_INTERVAL = "10"
    AUTO_RESTART = "false"
  }
}

resource "kubernetes_deployment" "onepassword_operator" {
  metadata {
    name = "onepassword-operator"
  }
  spec {
    revision_history_limit = 0
    replicas = 1
    selector {
      match_labels = {
        name = "onepassword-operator"
      }
    }
    template {
      metadata {
        labels = {
          name = "onepassword-operator"
        }
      }
      spec {
        service_account_name = "onepassword-connect-operator"
        container {
          name = "onepassword-operator"
          image = "1password/onepassword-operator:1.5"
          command = ["/manager"]
          env_from {
            config_map_ref {
              name = kubernetes_config_map.onepassword_operator.metadata.0.name
            }
          }
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "OP_CONNECT_TOKEN"
            value_from {
              secret_key_ref {
                name = "1password"
                key = "token"
              }
            }
          }
        }
      }
    }
  }
}