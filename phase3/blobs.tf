resource "nexus_blobstore_file" "npm_private" {
  name = "npm-private"
  path = "/nexus-data/npm-private"
}

resource "nexus_blobstore_file" "npm_proxy" {
  name = "npm-proxy"
  path = "/nexus-data/npm-proxy"
}

resource "nexus_blobstore_file" "npm_group" {
  name = "npm-group"
  path = "/nexus-data/npm-group"
}