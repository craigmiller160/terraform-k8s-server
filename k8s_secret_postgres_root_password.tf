resource "kubernetes_secret" "postgres_password" {
  metadata {
    name = "postgres-root-password"
  }

  data = {
    POSTGRES_ROOT_PASSWORD = var.postgres_root_password
  }
}