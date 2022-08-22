locals {
  cert_manager_crds_all = split("---", file("${path.module}/k8s_yaml/certmanager_crds.yml"))
  cert_manager_cert_requests = local.cert_manager_crds_all.0
  cert_manager_certificates = local.cert_manager_crds_all.1
  cert_manager_challenges_acme = local.cert_manager_crds_all.2
  cert_manager_cluster_issuers = local.cert_manager_crds_all.3
  cert_manager_issuers = local.cert_manager_crds_all.4
  cert_manager_orders_acme = local.cert_manager_crds_all.5
}

resource "kubernetes_manifest" "cert_manager_cert_requests" {
  manifest = yamldecode(local.cert_manager_cert_requests)
}

resource "kubernetes_manifest" "cert_manager_certificates" {
  manifest = yamldecode(local.cert_manager_certificates)
}

resource "kubernetes_manifest" "cert_manager_challenges_acme" {
  manifest = yamldecode(local.cert_manager_challenges_acme)
}

resource "kubernetes_manifest" "cert_manager_cluster_issuers" {
  manifest = yamldecode(local.cert_manager_cluster_issuers)
}

resource "kubernetes_manifest" "cert_manager_issuers" {
  manifest = yamldecode(local.cert_manager_issuers)
}

resource "kubernetes_manifest" "cert_manager_orders_acme" {
  manifest = yamldecode(local.cert_manager_orders_acme)
}