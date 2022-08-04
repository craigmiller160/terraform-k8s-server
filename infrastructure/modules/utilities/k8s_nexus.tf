locals {
  nexus_all_docs = split("---", file("${path.module}/k8s_yaml/nexus.yml"))
  nexus_deployment_doc = local.nexus_all_docs.0
  nexus_service_doc = local.nexus_all_docs.1
}