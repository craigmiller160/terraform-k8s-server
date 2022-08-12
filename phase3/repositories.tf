# Private NPM Repository (Hosted)
# NPM Proxy Repository
# NPM Repository Group

resource "nexus_repository_npm_hosted" "npm_private" {
  name = "npm-private"
  online = true

  storage {
    blob_store_name = nexus_blobstore_file.npm_private.name
    strict_content_type_validation = true
    write_policy = "ALLOW_ONCE"
  }
}