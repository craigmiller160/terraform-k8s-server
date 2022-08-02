
resource "kubernetes_secret" "onepassword" {
  metadata {
    name = "1password"
  }

  data = {
    credentials = base64decode(var.onepassword_creds)
    token = var.onepassword_token
  }
}

# TODO need TLS for this

resource "kubernetes_deployment" "onepassword" {
  metadata {
    name = "1password"
  }
  spec {
    revision_history_limit = 0
    replicas = 1
    selector {
      match_labels = {
        app = "1password"
      }
    }
    template {
      metadata {
        labels = {
          app = "1password"
        }
      }
      spec {
        container {
          name = "1password-connect"
          image = "1password/connect-api:1.5"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8081
          }
          volume_mount {
            mount_path = "/home/opuser/.op/data"
            name       = "1password-volume"
          }
          volume_mount {
            mount_path = "/home/opuser/.op/creds"
            name       = "1password-creds-secret-volume"
          }
          env {
            name = "OP_HTTP_PORT"
            value = "8081"
          }
          env {
            name = "OP_SESSION"
            value = "/home/opuser/.op/creds/credentials"
          }
        }
        container {
          name = "1password-sync"
          image = "1password/connect-sync:1.5"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8080
          }
          volume_mount {
            mount_path = "/home/opuser/.op/data"
            name       = "1password-volume"
          }
          volume_mount {
            mount_path = "/home/opuser/.op/creds"
            name       = "1password-creds-secret-volume"
          }
          env {
            name = "OP_SESSION"
            value = "/home/opuser/.op/creds/credentials"
          }
        }
        volume {
          name = "1password-volume"
          empty_dir {}
        }
        volume {
          name = "1password-creds-secret-volume"
          secret {
            secret_name = kubernetes_secret.onepassword.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "onepassword" {
  metadata {
    name = "onepassword-service"
  }
  spec {
    # TODO maybe make this ClusterIP, then it won't need TLS
    type = "NodePort"
    selector = {
      app = "1password"
    }
    port {
      port = 8081
      target_port = 8081
      node_port = 30010
    }
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
        service_account_name = "onepassword-operator"
        container {
          name = "onepassword-operator"
          image = "1password/onepassword-operator:1.5"
          command = ["/manager"]
          env {
            name = "WATCH_NAMESPACE"
            value = "default"
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
            name = "OPERATOR_NAME"
            value = "onepassword-operator"
          }
          env {
            name = "OP_CONNECT_HOST"
            value = "http://onepassword-service:8081"
          }
          env {
            name = "POLLING_INTERVAL"
            value = "10"
          }
          env {
            name = "OP_CONNECT_TOKEN"
            value_from {
              secret_key_ref {
                name = "onepassword"
                key = "token"
              }
            }
          }
          env {
            name = "AUTO_RESTART"
            value = "false"
          }
        }
      }
    }
  }
}