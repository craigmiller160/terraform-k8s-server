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

        path {
          path = "/covid-19"
          path_type = "Prefix"
          backend {
            service {
              name = "covid-19-client-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
#  spec {
#    rule {
#      http {
#        path {
#          path = "/nexus"
#          path_type = "Prefix"
#          backend {
#            service_name = "nexus-service"
#            service_port = 8081
#          }
#        }
#      }
#    }
#  }
}

#resource "kubernetes_config_map" "nginx_load_balancer_microk8s_conf" {
#  metadata {
#    name = "nginx-load-balancer-microk8s-conf"
#    namespace = "ingress"
#    annotations = {
#      "kubectl.kubernetes.io/last-applied-configuration" = "{\"apiVersion\":\"v1\",\"kind\":\"ConfigMap\",\"metadata\":{\"annotations\":{},\"name\":\"nginx-load-balancer-microk8s-conf\",\"namespace\":\"ingress\"}}"
#    }
#  }
#  data = {
#    use-forwarded-headers = "true"
#  }
#}

#locals {
#  nginx_load_balancer_doc = file("${path.module}/k8s_yaml/nginx-load-balancer-microk8s-conf.yml")
#}
#
#resource "kubernetes_manifest" "nginx_load_balancer_microk8s_conf" {
#  manifest = yamldecode(local.nginx_load_balancer_doc)
#  field_manager {
#    force_conflicts = true
#  }
#}