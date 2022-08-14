#resource "kubernetes_ingress" "ingress" {
#  metadata {
#
#  }
#  spec {}
#}

resource "kubernetes_config_map" "nginx_load_balancer_microk8s_conf" {
  metadata {
    name = "nginx-load-balancer-microk8s-conf"
    namespace = "ingress"
    annotations = {
      kubectl.kubernetes.io/last-applied-configuration = "{\"apiVersion\":\"v1\",\"kind\":\"ConfigMap\",\"metadata\":{\"annotations\":{},\"name\":\"nginx-load-balancer-microk8s-conf\",\"namespace\":\"ingress\"}}"
    }
  }
  data = {
    use-forwarded-headers = "true"
  }
}