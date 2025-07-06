include "backend" {
  path = find_in_parent_folders("aws-backend.hcl")
}

terraform {
  source = "github.com/ifbreadgood/tf-module-proxmox.git//vm?ref=e3a9bc496f03a32a782e4948368d5a5323600ada"
}

inputs = {
  name = "worker-3"
  node_name = "px"
  cpu = 8
  memory = 32768
  iso = "talos-metal-amd64-v1.10.5.iso"
  volume_size = 150
  ip = {
    address = "dhcp"
    # address = "10.0.1.10/24"
    # gateway = "10.0.1.1"
  }
  mac_address = "AA:AA:AA:AA:AA:DD"
}
