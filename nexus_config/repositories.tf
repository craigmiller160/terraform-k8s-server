# NPM Repository Group

resource "nexus_repository_npm_hosted" "npm_private" {
  depends_on = [
    nexus_blobstore_file.npm_private
  ]
  name   = "npm-private"
  online = true

  storage {
    blob_store_name                = nexus_blobstore_file.npm_private.name
    strict_content_type_validation = true
    write_policy                   = "ALLOW_ONCE"
  }
}

resource "nexus_repository_npm_proxy" "npm_proxy" {
  depends_on = [
    nexus_blobstore_file.npm_proxy
  ]
  name   = "npm-proxy"
  online = true

  storage {
    blob_store_name                = nexus_blobstore_file.npm_proxy.name
    strict_content_type_validation = true
  }

  proxy {
    remote_url       = "https://registry.npmjs.org"
    content_max_age  = 1440
    metadata_max_age = 1440
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  http_client {
    blocked    = false
    auto_block = true
  }
}

resource "nexus_repository_npm_group" "npm_group" {
  depends_on = [
    nexus_blobstore_file.npm_group,
    nexus_repository_npm_hosted.npm_private,
    nexus_repository_npm_proxy.npm_proxy
  ]
  name   = "npm-group"
  online = true

  storage {
    blob_store_name                = nexus_blobstore_file.npm_group.name
    strict_content_type_validation = true
  }

  group {
    member_names = [
      nexus_repository_npm_hosted.npm_private.name,
      nexus_repository_npm_proxy.npm_proxy.name
    ]
  }
}

resource "nexus_repository_docker_hosted" "docker_private" {
  depends_on = [
    nexus_blobstore_file.docker_private
  ]
  name   = "docker-private"
  online = true

  storage {
    blob_store_name                = nexus_blobstore_file.docker_private.name
    strict_content_type_validation = true
    write_policy                   = "ALLOW_ONCE"
  }

  docker {
    force_basic_auth = false
    v1_enabled       = true
    https_port       = 8083
  }
}

resource "nexus_repository_docker_proxy" "docker_proxy" {
  depends_on = [
    nexus_blobstore_file.docker_proxy
  ]
  name   = "docker-proxy"
  online = true

  storage {
    blob_store_name                = nexus_blobstore_file.docker_proxy.name
    strict_content_type_validation = true
  }

  docker {
    force_basic_auth = false
    v1_enabled       = false
  }

  docker_proxy {
    index_type = "HUB"
  }

  proxy {
    remote_url       = "https://registry-1.docker.io"
    content_max_age  = 1440
    metadata_max_age = 1440
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  http_client {
    blocked    = false
    auto_block = true
  }
}

resource "nexus_repository_docker_group" "docker_group" {
  depends_on = [
    nexus_blobstore_file.docker_group,
    nexus_repository_docker_hosted.docker_private,
    nexus_repository_docker_proxy.docker_proxy
  ]
  name   = "docker-group"
  online = true

  docker {
    force_basic_auth = false
    v1_enabled       = false
  }

  storage {
    blob_store_name                = nexus_blobstore_file.docker_group.name
    strict_content_type_validation = true
  }

  group {
    member_names = [
      nexus_repository_docker_hosted.docker_private.name,
      nexus_repository_docker_proxy.docker_proxy.name
    ]
    # TODO writeable_member may be a requirement for newer nexus versions
  }
}