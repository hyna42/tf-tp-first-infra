terraform {
  required_version = ">= v1.15.8" # Terraform minimum required version
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
    # Ansible provider, pour gérer l'inventaire
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.4.0"
    }
  }

}

# Configure the Libvirt Provider
provider "libvirt" {
  # Connection URI
  uri = "qemu:///system"
}
