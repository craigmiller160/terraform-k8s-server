resource "kubernetes_config_map" "mongodb" {
  metadata {
    name = "mongodb-config"
  }
  data = {
    MONGO_INITDB_ROOT_USERNAME = "mongo_root"
    MONGO_HOST = "mongodb-service"
    MONGO_AUTH_DB = "admin"
    MONGO_PORT = "27017"
  }
}

resource "kubernetes_secret" "mongodb_root_password" {
  metadata {
    name = "mongodb_root_password"
  }
  data = {
    MONGO_ROOT_PASSWORD = ""
  }
}