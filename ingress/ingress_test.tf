resource "kubernetes_deployment" "ingress_test" {
  metadata {
    name = "ingress-test"
    namespace = "default"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "ingress-test"
      }
    }
    template {
      metadata {
        labels = {
          app = "ingress-test"
        }
      }
      spec {
        container {
          name = "ingress-test"
          image = "nginxdemos/hello"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ingress_test_service" {
  metadata {
    name = "ingress-test-service"
    namespace = "default"
  }
  spec {
    type = "NodePort"
    selector = {
      app = "ingress-test"
    }
    port {
      port = 80
      target_port = 80
      node_port = 30019
    }
  }
}