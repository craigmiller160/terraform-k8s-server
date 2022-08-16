resource "nexus_security_user" "craigmiller160" {
  userid    = "craigmiller160"
  firstname = "Craig"
  lastname  = "Miller"
  email     = "craigmiller160@gmail.com"
  password  = var.nexus_craig_password
  roles     = ["nx-admin", "nx-anonymous"]
  status    = "active"
}