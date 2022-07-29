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
          # TODO need configmap
          # TODO need secret
          # TODO need volumes
        }
      }
    }
  }
}