include "backend" {
  path   = find_in_parent_folders("aws-backend.hcl")
  expose = true
}

locals {
  tf_root = include.backend.locals.path_from_include
}

dependency "service_account_token" {
  config_path = "../main-cluster-service-account"
}

dependency "talos" {
  config_path = "${local.tf_root}/main-cluster/prod/proxmox/local/talos"
}

inputs = {
  kubernetes_ca_cert = dependency.talos.outputs.kube_config.ca_certificate
  kubernetes_host    = dependency.talos.outputs.kube_config.host
  token_reviewer_jwt = dependency.service_account_token.outputs.token
}