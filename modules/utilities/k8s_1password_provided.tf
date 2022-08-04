data "onepassword_service_account" "documents" {
  abc = "def"
  content = abc
#  content = split(file("${path.module}/k8s_yaml/1password_provided/1password_service_account.yml"))
}

resource "kubernetes_manifest" "onepassword_provided_item" {
  manifest = yamldecode(file("${path.module}/k8s_yaml/1password_provided/1password_item.yml"))
}

resource "kubernetes_manifest" "onepassword_provided_service_account" {
  manifest = yamldecode(data.onepassword_service_account_documents)
}