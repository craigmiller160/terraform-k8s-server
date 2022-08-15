resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "cluster-ingress"
  }
  spec {
    rule {
      http {
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

#        path {
#          path = "/covid-19"
#          path_type = "Prefix"
#          backend {
#            service {
#              name = "covid-19-client-service"
#              port {
#                number = 443
#              }
#            }
#          }
#        }
#
#        path {
#          path = "/funcoast-hi"
#          path_type = "Prefix"
#          backend {
#            service {
#              name = "funcoast-hi-client-service"
#              port {
#                number = 443
#              }
#            }
#          }
#        }
#
#        path {
#          path = "/auth-management"
#          path_type = "Prefix"
#          backend {
#            service {
#              name = "auth-management-ui-service"
#              port {
#                number = 443
#              }
#            }
#          }
#        }
#
#        path {
#          path = "/video-manager"
#          path_type = "Prefix"
#          backend {
#            service {
#              name = "video-manager-client-service"
#              port {
#                number = 443
#              }
#            }
#          }
#        }
      }
    }
  }
}