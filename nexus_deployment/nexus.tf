resource "kubernetes_deployment" "nexus" {
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
          image = "busybox:1.28"
          image_pull_policy = "IfNotPresent"
          command = ["/bin/sh"]
          args = [
            "-c",
            "chown -R 200:200 /nexus-data"
          ]
          volume_mount {
            mount_path = "/nexus-data"
            name       = "nexus-data-volume"
          }
        }
        container {
          name = "nexus"
          image = var.nexus_image
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8081
          }
          port {
            container_port = 8083
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
    type = "ClusterIP"
    selector = {
      app = "nexus"
    }
    port {
      name = "standard"
      port = 8081
      target_port = 8081
      protocol = "TCP"
    }
    port {
      name = "docker-http"
      port = 8083
      target_port = 8083
      protocol = "TCP"
    }
  }
}