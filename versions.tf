terraform {
  required_version = ">= v1.15.8" # Terraform minimum required version
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

# Configure the Libvirt Provider
provider "libvirt" {
  # Connection URI
  uri = "qemu:///system"
}
