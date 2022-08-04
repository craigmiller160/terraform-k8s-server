#resource "kubernetes_manifest" "onepassword_provided_item" {
#  manifest = yamldecode(file("${path.module}/k8s_yaml/1password_provided/1password_item.yml"))
#}

resource "kubernetes_manifest" "onepassword_provided_service_account" {
  manifest = yamldecode(file("${path.module}/k8s_yaml/1password_provided/1password_service_account.yml"))
}