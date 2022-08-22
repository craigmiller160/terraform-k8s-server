resource "kubernetes_manifest" "onepassword_provided_item" {
  manifest = yamldecode(file("${path.module}/k8s_yaml/1password_crd.yml"))
}