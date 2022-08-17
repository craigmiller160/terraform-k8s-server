resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "cluster-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class" = "public"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
#    tls {
#      hosts = ["craigmiller160.ddns.net"]
#    }
    rule {
      host = "dev.cluster"
      http {
        path {
          path = "/ingress-test"
          path_type = "Prefix"
          backend {
            service {
              name = "ingress-test-service"
              port {
                number = 80
              }
            }
          }
        }

        path {
          path = "/nexus"
          path_type = "Prefix"
          backend {
            service {
              name = "nexus-service"
              port {
                number = 8081
              }
            }
          }
        }
      }
    }
  }
}