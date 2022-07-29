resource "kubernetes_config_map" "postgres" {
  metadata {
    name = "postgres-config"
  }
  data = {
    POSTGRES_USER = "postgres_root"
  }
}

resource "kubernetes_secret" "postgres_password" {
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
    replicas = 1
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
        container {
          name = "postgres"
          image = "postgres:12.5"
          # TODO need args for ssl certs
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 5432
          }
          env_from {
            config_map_ref {
              name = "postgres-config"
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "postgres-root-password"
                key = "POSTGRES_ROOT_PASSWORD"
              }
            }
          }
          # TODO need volumes
        }
      }
    }
  }
}