# TODO delete all locals
locals {
  postgres_all_docs = split("---", file("${path.module}/k8s_yaml/postgres.yml"))
  postgres_deployment_doc = local.postgres_all_docs.0
  postgres_service_doc = local.postgres_all_docs.1
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
    namespace = "default"
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
        init_container {
          name = "prepare-certs"
          image = "busybox:1.28"
          image_pull_policy = "IfNotPresent"
          command = [
            "sh",
            "-c",
            "cat /certs-secret/cert | base64 -d > /certs/cert && cat /certs-secret/key | base64 -d > /certs/key && chmod 600 /certs/* && chown 999 /certs/*"
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
          name = "postgres"
          image = "postgres:12.5"
          image_pull_policy = "IfNotPresent"
          args = [
            "-c",
            "ssl=on",
            "-c",
            "ssl_cert_file=/var/lib/postgresql/certs/cert",
            "-c",
            "ssl_key_file=/var/lib/postgresql/certs/key"
          ]
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
                key = "password"
              }
            }
          }
        }
        volume {
          name = "postgres-volume"
          host_path {
            path = "/opt/kubernetes/data/postgres"
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

resource "kubernetes_manifest" "postgres_service" {
  manifest = yamldecode(local.postgres_service_doc)
}