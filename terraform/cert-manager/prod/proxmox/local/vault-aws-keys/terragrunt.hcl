include "backend" {
  path = find_in_parent_folders("aws-backend.hcl")
  expose = true
}

locals {
  tf_root = include.backend.locals.path_from_include
}

dependencies {
  paths = ["${local.tf_root}/vault/prod/proxmox/local/auth-kubernetes"]
}

inputs = {
  name = "cert-manager"
}