
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
          env {
            name = "OP_HTTP_PORT"
            value = "8081"
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
        }
        volume {
          name = "1password-volume"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "onepassword" {
  metadata {
    name = "1password-service"
  }
  spec {
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