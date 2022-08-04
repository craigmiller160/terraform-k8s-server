#data "onepassword_service_account" "documents" {
#  content = split()
#}

locals {
  all_service_account_docs = split("---", file("${path.module}/k8s_yaml/1password_provided/1password_service_account.yml"))
  service_account_doc = local.all_service_account_docs.0
}

#resource "kubernetes_manifest" "onepassword_provided_item" {
#  manifest = yamldecode(file("${path.module}/k8s_yaml/1password_provided/1password_item.yml"))
#}

resource "kubernetes_manifest" "onepassword_provided_service_account" {
  manifest = yamldecode(local.service_account_doc)
}