resource "kubernetes_secret" "database_tls_certs" {
  metadata {
    name = "database-tls-certs"
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = base64decode(var.database_cert)
    "tls.key" = base64decode(var.database_key)
  }
}