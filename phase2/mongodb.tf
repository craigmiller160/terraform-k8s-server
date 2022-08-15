resource "kubernetes_config_map" "mongodb_config" {
  metadata {
    name = "mongodb-config"
    namespace = "default"
  }
  data = {
    MONGO_HOST = "mongodb-service"
    MONGO_AUTH_DB = "admin"
    MONGO_PORT = "27017"
  }
}

resource "kubernetes_deployment" "mongodb" {
  depends_on = [
    kubernetes_config_map.mongodb_config,
    kubernetes_manifest.secret_database_tls_certs,
    kubernetes_manifest.secret_mongodb_root_account
  ]
  metadata {
    name = "mongodb"
    namespace = "default"
  }
  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
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
          image_pull_policy = "IfNotPresent"
          command = [
            "sh",
            "-c",
            "cat /certs-secret/cert | base64 -d > /certs/mongodb.pem && cat /certs-secret/key | base64 -d >> /certs/mongodb.pem"
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
          name = "mongodb"
          image = "mongo:4.4.2"
          image_pull_policy = "IfNotPresent"
          args = [
            "--tlsMode",
            "requireTLS",
            "--tlsCertificateKeyFile",
            "/certs/mongodb.pem"
          ]
          port {
            container_port = 27017
          }
          env_from {
            config_map_ref {
              name = "mongodb-config"
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
          env {
            name = "MONGO_INITDB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mongodb-root-account"
                key = "password"
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
            secret_name = "database-tls-certs"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mongodb_service" {
  metadata {
    name = "mongodb-service"
    namespace = "default"
  }
  spec {
    type = "NodePort"
    selector = {
      app = "mongodb"
    }
    port {
      port = "27017"
      target_port = "27017"
      node_port = "30002"
    }
  }
}