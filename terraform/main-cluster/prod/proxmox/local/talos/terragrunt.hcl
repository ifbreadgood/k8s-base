include "backend" {
  path = find_in_parent_folders("aws-backend.hcl")
}

inputs = {
  cluster_name        = "talos"
  controller_endpoint = "10.0.1.10"
  controller_ips      = ["10.0.1.10"]
  worker_ips          = ["10.0.1.11", "10.0.1.12", "10.0.1.13"]
  talos_version       = "1.10.5"
}

dependencies {
  paths = [
    "../vm/controller",
    "../vm/worker-1",
    "../vm/worker-2",
    "../vm/worker-3"
  ]
}