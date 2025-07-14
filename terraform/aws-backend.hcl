locals {
  path        = regex("(?P<application>[^/]+)/(?P<environment>[^/]+)/(?P<platform>[^/]+)/(?P<location>[^/]+)/(?P<rest>[^/]+).*", path_relative_to_include())
  project     = "kubernetes"
  application = local.path.application
  environment = local.path.environment
  platform    = local.path.platform
  location    = local.path.location
  rest        = local.path.rest
  default_tags = {
    project     = "kubernetes"
    application = local.path.application
    environment = local.environment
    platform    = local.platform
    location    = local.location
    rest        = local.rest
  }
  path_from_include = path_relative_from_include()
  path_to_include   = path_relative_to_include()
}

generate "backend" {
  path      = "_backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      backend "s3" {
        region         = "us-east-2"
        bucket         = "tf-state-${get_aws_account_id()}-primary"
        key            = "${path_relative_to_include()}/terraform.tfstate"
        encrypt        = true
        use_lockfile   = true
      }
    }
    EOF
}