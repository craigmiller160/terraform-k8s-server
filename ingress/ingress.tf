# TODO document the three hostnames
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
    tls {
      hosts = [
        var.ingress_cluster_hostname,
        var.ingress_nexus_hostname,
        var.ingress_nexus_docker_hostname
      ]
      secret_name = "craigmiller160-tls-certs"
    }
    rule {
      host = var.ingress_nexus_hostname
      http {
        path {
          path = "/"
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
    rule {
      host = var.ingress_nexus_docker_hostname
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "nexus-service"
              port {
                number = 8083
              }
            }
          }
        }
      }
    }
    rule {
      host = var.ingress_cluster_hostname
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
          path = "/covid-19"
          path_type = "Prefix"
          backend {
            service {
              name = "covid-19-client-service"
              port {
                number = 443
              }
            }
          }
        }

        path {
          path = "/video-manager"
          path_type = "Prefix"
          backend {
            service {
              name = "video-manager-client-service"
              port {
                number = 443
              }
            }
          }
        }

        path {
          path = "/auth-management"
          path_type = "Prefix"
          backend {
            service {
              name = "auth-management-ui-service"
              port {
                number = 443
              }
            }
          }
        }

        path {
          path = "/funcoast-hi"
          path_type = "Prefix"
          backend {
            service {
              name = "funcoast-hi-client-service"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}