include "backend" {
  path = find_in_parent_folders("aws-backend.hcl")
}

terraform {
  source = "github.com/ifbreadgood/tf-module-keycloak.git//openid-client?ref=b85de81eed7df9806af1b7d0a554fa152cc7d556"
}

inputs = {
  realm_name  = "onprem"
  client_name = "argo-cd"
  client_id   = "argo-cd"
  valid_redirect_uris = [
    "https://argo-cd.trial.studio/auth/callback",
    "https://argo-cd.trial.studio/api/dex/callback"
  ]
}