config {
  module = true
  force = false
  disabled_by_default = false
  variables = ["k8s_context=kind"]
  varfile = ["secrets.tfvars"]
}