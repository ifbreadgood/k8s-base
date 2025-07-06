include "backend" {
  path = find_in_parent_folders("aws-backend.hcl")
}

inputs = {
  name = "cert-manager"
}