resource "kubernetes_secret" "database_tls_certs" {
  metadata {
    name = "database-tls-certs"
  }
  type = "kubernetes.io/tls"
}