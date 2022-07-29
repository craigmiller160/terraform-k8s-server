resource "kubernetes_config_map" "postgres" {
  metadata {
    name = "postgres-config"
  }
  data = {
    POSTGRES_USER = "postgres_root"
  }
}