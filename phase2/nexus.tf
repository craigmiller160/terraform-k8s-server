# TODO still needs major cleanup
resource "kubernetes_deployment" "nexus" {
  depends_on = [
    kubernetes_manifest.secret_craigmiller160_tls_certs
  ]
  metadata {
    name = "nexus"
    namespace = "default"
  }
  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "nexus"
      }
    }
    template {
      metadata {
        labels = {
          app = "nexus"
        }
      }
      spec {
        init_container {
          name = "setup"
          image = "alpine:3.15.5"
          image_pull_policy = "IfNotPresent"
          command = ["/bin/sh"]
          args = [
            "-c",
            <<EOF
              chown -R 200:200 /nexus-data &&
              apk add openssl &&
              cat /secret-certs/key | base64 -d > /certs/key-decoded &&
              cat /secret-certs/cert | base64 -d > /certs/cert-decoded &&
              openssl pkcs12 -export -out /certs/nexus.p12 -inkey /certs/key-decoded -in /certs/cert-decoded -password pass:password
            EOF
          ]
          volume_mount {
            mount_path = "/nexus-data"
            name       = "nexus-data-volume"
          }
          volume_mount {
            mount_path = "/secret-certs"
            name       = "nexus-secret-certs-volume"
          }
          volume_mount {
            mount_path = "/certs"
            name       = "nexus-certs-volume"
          }
        }
        container {
          name = "nexus"
          image = var.nexus_image
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8081
          }
          volume_mount {
            mount_path = "/nexus-data"
            name       = "nexus-data-volume"
          }
        }
        volume {
          name = "nexus-data-volume"
          host_path {
            path = "/opt/kubernetes/data/nexus/data"
          }
        }
        volume {
          name = "nexus-secret-certs-volume"
          secret {
            secret_name = "craigmiller160-tls-certs"
          }
        }
        volume {
          name = "nexus-certs-volume"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "nexus_service" {
  metadata {
    name = "nexus-service"
    namespace = "default"
  }
  spec {
    type = "NodePort"
    selector = {
      app = "nexus"
    }
    port {
      name = "standard"
      port = 8081
      target_port = 8081
      node_port = 30003
      protocol = "TCP"
    }
    port {
      name = "docker-http"
      port = 8083
      target_port = 8083
      node_port = 30003
      protocol = "TCP"
    }
  }
}