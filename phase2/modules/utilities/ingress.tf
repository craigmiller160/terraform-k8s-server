#resource "kubernetes_ingress" "ingress" {
#  metadata {
#
#  }
#  spec {}
#}

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