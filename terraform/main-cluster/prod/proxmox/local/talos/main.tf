terraform {
  required_version = "~> 1.12.0"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.8.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

provider "talos" {}

variable "cluster_name" {
  type = string
}

variable "controller_endpoint" {
  type = string
}

variable "controller_ips" {
  type = set(string)
}

variable "worker_ips" {
  type = set(string)
}

variable "talos_version" {
  type = string
}

resource "talos_machine_secrets" "this" {}

locals {
  config_patches = [
    file("patch/no-cni-proxy.yaml"),
    file("patch/local-mount.yaml"),
    file("patch/unrestricted-namespace.yaml"),
    file("patch/name-server.yaml"),
    file("patch/authentication.yaml")
  ]
  cluster_endpoint = "https://${var.controller_endpoint}:6443"
}

data "talos_machine_configuration" "controller" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
  config_patches   = local.config_patches
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_machine_configuration_apply" "controller" {
  for_each                    = var.controller_ips
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller.machine_configuration
  node                        = each.value
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
  config_patches   = local.config_patches
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = var.worker_ips
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.controller]
  node                 = var.controller_endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.controller_endpoint
}

resource "local_file" "kube_config" {
  filename             = "/workspace/kube-contexts/talos"
  content              = talos_cluster_kubeconfig.this.kubeconfig_raw
  file_permission      = "0600"
  directory_permission = "0700"
}

output "client_configuration" {
  value     = talos_machine_secrets.this.client_configuration
  sensitive = true
}

output "kube_config" {
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration
  sensitive = true
}