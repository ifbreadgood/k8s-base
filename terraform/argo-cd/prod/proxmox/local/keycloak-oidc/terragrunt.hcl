include "backend" {
  path = find_in_parent_folders("aws-backend.hcl")
}

terraform {
  source = "github.com/ifbreadgood/tf-module-keycloak.git//openid-client?ref=8aa2fe26575a7c2a4d666576826c66ce0f509a9c"
}

locals {
  base_url = "https://argo-cd.trial.studio"
}

inputs = {
  realm_name  = "onprem"
  client_name = "argo-cd"
  client_id   = "argo-cd"
  access_type = "PUBLIC"
  valid_redirect_uris = [
    "${local.base_url}/auth/callback",
    "${local.base_url}/api/dex/callback",
    "${local.base_url}/pkce/verify"
  ]
  root_url = local.base_url
  base_url = "/applications"
}