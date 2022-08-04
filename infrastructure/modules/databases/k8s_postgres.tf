resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    revision_history_limit = 0
    replicas               = 1
    selector {
      match_labels = {
        app = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }
      spec {
        init_container {
          name = "prepare-certs"
          image = "busybox:1.28"
          command = [
            "sh",
            "-c",
            "cp /certs-secret/* /certs && chmod 600 /certs/* && chown 999 /certs/*"
          ]
          volume_mount {
            mount_path = "/certs-secret"
            name       = "postgres-certs-secret-volume"
          }
          volume_mount {
            mount_path = "/certs"
            name       = "postgres-certs-volume"
          }
        }
        container {
          name  = "postgres"
          image = "postgres:12.5"
          args = [
            "-c",
            "ssl=on",
            "-c",
            "ssl_cert_file=/var/lib/postgresql/certs/tls.crt",
            "-c",
            "ssl_key_file=/var/lib/postgresql/certs/tls.key"
          ]
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 5432
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = "postgres-root-account"
                key = "username"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "postgres-root-account"
                key  = "password"
              }
            }
          }
          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "postgres-volume"
          }
          volume_mount {
            mount_path = "/var/lib/postgresql/certs"
            name       = "postgres-certs-volume"
          }
        }

        volume {
          name = "postgres-volume"
          host_path {
            path = "/opt/kubernetes/data/postgres"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "postgres-certs-volume"
          empty_dir {}
        }

        volume {
          name = "postgres-certs-secret-volume"
          secret {
            secret_name = kubernetes_secret.database_tls_certs.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres-service"
  }
  spec {
    type = "NodePort"
    selector = {
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
      node_port   = 30001
    }
  }
}