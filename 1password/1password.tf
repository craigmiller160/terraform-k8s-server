
locals {
  onepassword_secret_values_all_docs = split("---", file("${path.module}/k8s_yaml/1password_secret_values.yml"))
  onepassword_secret_values_mongodb_root_account_doc = local.onepassword_secret_values_all_docs.0
  onepassword_secret_values_postgres_root_account_doc = local.onepassword_secret_values_all_docs.1
  onepassword_secret_values_database_tls_doc = local.onepassword_secret_values_all_docs.2
  onepassword_secret_values_craigmiller160_tls_doc = local.onepassword_secret_values_all_docs.3
}

resource "kubernetes_secret" "onepassword" {
  metadata {
    name = "onepassword"
  }

  data = {
    credentials = base64decode(var.onepassword_creds)
    token = var.onepassword_token
  }
}

resource "kubernetes_config_map" "onepassword_connect_config" {
  metadata {
    name = "onepassword-connect-config"
    namespace = "default"
  }
  data = {
    OP_HTTP_PORT = "8081"
    OP_SESSION = "/home/opuser/.op/creds/credentials"
  }
}

resource "kubernetes_config_map" "onepassword_sync_config" {
  metadata {
    name = "onepassword-sync-config"
    namespace = "default"
  }
  data = {
    OP_SESSION = "/home/opuser/.op/creds/credentials"
  }
}

resource "kubernetes_deployment" "onepassword_connect_sync_deployment" {
  depends_on = [
    kubernetes_secret.onepassword,
    kubernetes_config_map.onepassword_connect_config,
    kubernetes_config_map.onepassword_sync_config
  ]
  metadata {
    name = "onepassword-connect-sync"
    namespace = "default"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "onepassword-connect-sync"
      }
    }
    template {
      metadata {
        labels = {
          app = "onepassword-connect-sync"
        }
      }
      spec {
        container {
          name = "onepassword-connect"
          image = "1password/connect-api:1.5"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8081
          }
          volume_mount {
            mount_path = "/home/opuser/.op/data"
            name       = "onepassword-volume"
          }
          volume_mount {
            mount_path = "/home/opuser/.op/creds"
            name       = "onepassword-creds-secret-volume"
          }
          env_from {
            config_map_ref {
              name = "onepassword-connect-config"
            }
          }
        }
        container {
          name = "onepassword-sync"
          image = "1password/connect-sync:1.5"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8080
          }
          volume_mount {
            mount_path = "/home/opuser/.op/data"
            name       = "onepassword-volume"
          }
          volume_mount {
            mount_path = "/home/opuser/.op/creds"
            name       = "onepassword-creds-secret-volume"
          }
          env_from {
            config_map_ref {
              name = "onepassword-sync-config"
            }
          }
        }
        volume {
          name = "onepassword-volume"
          empty_dir {}
        }
        volume {
          name = "onepassword-creds-secret-volume"
          secret {
            secret_name = "onepassword"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "onepassword_connect_service" {
  metadata {
    name = "onepassword-connect-service"
    namespace = "default"
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "onepassword-connect-sync"
    }
    port {
      port = 8081
      target_port = 8081
    }
  }
}

resource "kubernetes_config_map" "onepassword_connect_operator_config" {
  metadata {
    name = "onepassword-connect-operator-config"
    namespace = "default"
  }
  data = {
    WATCH_NAMESPACE = "default"
    OPERATOR_NAME = "onepassword-connect-operator"
    OP_CONNECT_HOST = "http://onepassword-connect-service:8081"
    POLLING_INTERVAL = "10"
    AUTO_RESTART = "false"
  }
}

resource "kubernetes_deployment" "onepassword_connect_operator" {
  depends_on = [
    kubernetes_config_map.onepassword_connect_operator_config,
    kubernetes_deployment.onepassword_connect_sync_deployment,
    kubernetes_service.onepassword_connect_service,
    kubernetes_manifest.onepassword_connect_operator_service_account,
    kubernetes_cluster_role_binding.onepassword_connect_operator_cluster_role_binding,
    kubernetes_cluster_role.onepassword_connect_operator_cluster_role
  ]
  metadata {
    name = "onepassword-connect-operator"
    namespace = "default"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "onepassword-connect-operator"
      }
    }
    template {
      metadata {
        labels = {
          name = "onepassword-connect-operator"
        }
      }
      spec {
        service_account_name = "onepassword-connect-operator"
        container {
          name = "onepassword-connect-operator"
          image = "1password/onepassword-operator:1.5"
          command = ["/manager"]
          env_from {
            config_map_ref {
              name = "onepassword-connect-operator-config"
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
                name = "onepassword"
                key = "token"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "secret_mongodb_root_account" {
  depends_on = [kubernetes_deployment.onepassword_connect_operator]
  manifest = yamldecode(local.onepassword_secret_values_mongodb_root_account_doc)
}

resource "kubernetes_manifest" "secret_postgres_root_account" {
  depends_on = [kubernetes_deployment.onepassword_connect_operator]
  manifest = yamldecode(local.onepassword_secret_values_postgres_root_account_doc)
}

resource "kubernetes_manifest" "secret_database_tls_certs" {
  depends_on = [kubernetes_deployment.onepassword_connect_operator]
  manifest = yamldecode(local.onepassword_secret_values_database_tls_doc)
}

resource "kubernetes_manifest" "secret_craigmiller160_tls_certs" {
  depends_on = [kubernetes_deployment.onepassword_connect_operator]
  manifest = yamldecode(local.onepassword_secret_values_craigmiller160_tls_doc)
}