# --- DHCP Network ---
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}
resource "libvirt_network" "this" {
  name      = var.network_name
  autostart = true
  forward = {
    mode = "nat"
  }
  ips = [{
    address = cidrhost(var.cidr, 1)
    netmask = cidrnetmask(var.cidr)
    dhcp = {
      ranges = [{
        start = cidrhost(var.cidr, 100), end = cidrhost(var.cidr, 200)
      }]
    }

  }]
}