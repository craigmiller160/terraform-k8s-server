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
              name = "exp-service"
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