resource "kubernetes_config_map" "postgres" {
  metadata {
    name = "postgres-config"
  }
  data = {
    POSTGRES_USER = "postgres_root"
  }
}

resource "kubernetes_secret" "postgres_root_password" {
  metadata {
    name = "postgres-root-password"
  }

  data = {
    POSTGRES_ROOT_PASSWORD = var.postgres_root_password
  }
}

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
          name = "experiment"
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
          env_from {
            config_map_ref {
              name = kubernetes_config_map.postgres.metadata.0.name
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_root_password.metadata.0.name
                key  = "POSTGRES_ROOT_PASSWORD"
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
            secret_name = "database-tls-certs"
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