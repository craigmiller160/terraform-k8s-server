resource "kubernetes_secret" "database_tls_certs" {
  metadata {
    name = "database-tls-certs"
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.cert" = var.database_cert
    "tls.key" = var.database_key
  }
}