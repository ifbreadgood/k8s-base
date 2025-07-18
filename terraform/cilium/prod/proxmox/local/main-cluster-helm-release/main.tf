terraform {
  required_version = "~> 1.12.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = var.kube_config.host
    cluster_ca_certificate = base64decode(var.kube_config.ca_certificate)
    client_certificate     = base64decode(var.kube_config.client_certificate)
    client_key             = base64decode(var.kube_config.client_key)
  }
}

variable "kube_config" {
  type = object({
    ca_certificate     = string
    client_certificate = string
    client_key         = string
    host               = string
  })
}

variable "repo_root_path" {
  type = string
}

variable "repository" {
  type = string
}

variable "name" {
  type = string
}

variable "chart_version" {
  type = string
}

resource "helm_release" "this" {
  repository       = var.repository
  chart            = var.name
  version          = var.chart_version
  name             = var.name
  namespace        = var.name
  create_namespace = true
  atomic           = true
  timeout          = 5 * 60
  values           = [file("${var.repo_root_path}/kubernetes/helm-values/cilium/values.yaml")]
}