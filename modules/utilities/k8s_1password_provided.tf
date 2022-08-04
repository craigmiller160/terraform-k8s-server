resource "kubernetes_manifest" "onepassword_provided_item" {
  manifest = yamldecode(file("${path.module}/onepassword_item.yml"))
}