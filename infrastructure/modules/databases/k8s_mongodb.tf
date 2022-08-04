resource "kubernetes_config_map" "mongodb" {
  metadata {
    name = "mongodb-config"
  }
  data = {
    MONGO_HOST                 = "mongodb-service"
    MONGO_AUTH_DB              = "admin"
    MONGO_PORT                 = "27017"
  }
}

resource "kubernetes_deployment" "mongodb" {
  metadata {
    name = "mongodb"
  }
  spec {
    revision_history_limit = 0
    replicas               = 1
    selector {
      match_labels = {
        app = "mongodb"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongodb"
        }
      }
      spec {
        init_container {
          name = "prepare-certs"
          image = "busybox:1.28"
          command = [
            "sh",
            "-c",
            "cat /certs-secret/tls.crt > /certs/mongodb.pem && cat /certs-secret/tls.key >> /certs/mongodb.pem"
          ]
          volume_mount {
            mount_path = "/certs-secret"
            name       = "mongodb-certs-secret-volume"
          }
          volume_mount {
            mount_path = "/certs"
            name       = "mongodb-certs-volume"
          }
        }
        container {
          name  = "mongodb"
          image = "mongo:4.4.2"
          args = [
            "--tlsMode",
            "requireTLS",
            "--tlsCertificateKeyFile",
            "/certs/mongodb.pem"
          ]
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 27017
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.mongodb.metadata.0.name
            }
          }
          env {
            name = "MONGO_INITDB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mongodb-root-account"
                key  = "password"
              }
            }
          }
          env {
            name = "MONGO_INITDB_ROOT_USERNAME"
            value_from {
              secret_key_ref {
                name = "mongodb-root-account"
                key = "username"
              }
            }
          }
          volume_mount {
            mount_path = "/data/db"
            name       = "mongodb-volume"
          }
          volume_mount {
            mount_path = "/certs"
            name       = "mongodb-certs-volume"
          }
        }
        volume {
          name = "mongodb-volume"
          host_path {
            path = "/opt/kubernetes/data/mongodb"
          }
        }
        volume {
          name = "mongodb-certs-volume"
          empty_dir {}
        }
        volume {
          name = "mongodb-certs-secret-volume"
          secret {
            secret_name = kubernetes_secret.database_tls_certs.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mongodb" {
  metadata {
    name = "mongodb-service"
  }
  spec {
    type = "NodePort"
    selector = {
      app = "mongodb"
    }
    port {
      port        = 27017
      target_port = 27017
      node_port   = 30002
    }
  }
}