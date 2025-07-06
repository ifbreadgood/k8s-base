include "backend" {
  path   = find_in_parent_folders("aws-backend.hcl")
  expose = true
}

locals {
  tf_root = include.backend.locals.path_from_include
}

dependency "talos" {
  config_path = "${local.tf_root}/main-cluster/prod/proxmox/local/talos"
}

inputs = {
  kube_config    = dependency.talos.outputs.kube_config
  repo_root_path = get_path_to_repo_root()
  name           = "argo-cd-apps"
  namespace = "argo-cd"
}