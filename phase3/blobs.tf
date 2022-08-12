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

resource "nexus_blobstore_file" "docker_private" {
  name = "docker-private"
  path = "/nexus-data/docker-private"
}

resource "nexus_blobstore_file" "docker_proxy" {
  name = "docker-proxy"
  path = "/nexus-data/docker-proxy"
}

resource "nexus_blobstore_file" "docker_group" {
  name = "docker-group"
  path = "/nexus-data/docker-group"
}