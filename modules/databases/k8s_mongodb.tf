resource "kubernetes_config_map" "mongodb" {
  metadata {
    name = "mongodb-config"
  }
  data = {
    MONGO_INITDB_ROOT_USERNAME = "mongo_root"
    MONGO_HOST                 = "mongodb-service"
    MONGO_AUTH_DB              = "admin"
    MONGO_PORT                 = "27017"
  }
}

resource "kubernetes_secret" "mongodb_root_password" {
  metadata {
    name = "mongodb-root-password"
  }
  data = {
    MONGO_ROOT_PASSWORD = var.mongodb_root_password
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
        container {
          name  = "mongodb"
          image = "mongo:4.4.2"
          # TODO need args for tls
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
                name = kubernetes_secret.mongodb_root_password.metadata.0.name
                key  = "MONGO_ROOT_PASSWORD"
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