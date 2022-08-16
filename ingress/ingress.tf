# TODO ingress crashes and completely dies far too easily if a path ends in 404
# TODO need to add other prod services here
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "cluster-ingress"
  }
  spec {
    rule {
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