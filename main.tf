locals {
  vm_name  = "lab-vm"
  hostname = "webserver"
}
# --- DHCP Network ---
resource "libvirt_network" "lab_net" {
  name      = "lab-net"
  autostart = false
  forward = {
    mode = "nat"
  }
  ips = [{
    address = "10.20.0.1"
    netmask = "255.255.255.0"
    dhcp = {
      ranges = [{
        start = "10.20.0.100", end = "10.20.0.200"
      }]
    }

  }]
}

# --- Volume disk ---
resource "libvirt_volume" "disk" {
  name = "${local.vm_name}.qcow2" # file name in the pool
  pool = "default"                # target pool (default = /var/lib/libvirt/images)
  target = {
    format = {
      type = "qcow2" # disk format
    }
  }

  create = {
    content = {
      url = "/var/lib/libvirt/images/base/noble-server-cloudimg-amd64.img" # Image source local

    }
  }
}

# --- Cloud-init : génération de l'ISO Cloud-Init (mémoire vive) ---
resource "libvirt_cloudinit_disk" "init" {
  name = "${local.vm_name}-init.iso"
  user_data = templatefile("${path.module}/cloud-init/user-data.yaml", {
    ssh_key  = trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))
    hostname = local.hostname, #variable passé au template
  })
  meta_data = yamlencode({
    instance-id    = "${local.vm_name}-01"
    local-hostname = "${local.hostname}"
  })
}

# --- Cloud-init : création du volume physique contenant l'ISO ---
resource "libvirt_volume" "cloudinit" {
  name = "${local.vm_name}-cloudinit-config"
  pool = "default"
  create = {
    content = {
      url = libvirt_cloudinit_disk.init.path
    }
  }
}

# --- Domaine (VM) ---
resource "libvirt_domain" "vm" {
  name        = local.vm_name # VM name in libvirt
  type        = "kvm"         # Hyperviseur (KVM)
  memory      = 512
  memory_unit = "MiB"
  vcpu        = 1 # vCPUs number


  os = {
    type         = "hvm"    # Hardware Virtual Machine
    type_arch    = "x86_64" # Architecture cible
    type_machine = "q35"    # Chipset virtuel
  }

  devices = {
    disks = [
      # OS - Disk
      {
        source = {
          file = {
            file = libvirt_volume.disk.path # Volume reference
          }
        }
        target = {
          dev = "vda"
          bus = "virtio" # Disque principal virtio
        }
        driver = { name = "qemu", type = "qcow2" }
      },
      # Cloud-init disk
      {
        device = "cdrom"
        driver = { name = "qemu", type = "raw" }
        source = {
          file = {
            file = libvirt_volume.cloudinit.path # Volume reference
          }

        }
        target = { dev = "sda", bus = "sata" }
      }

    ]
    interfaces = [
      # {
      #   type = "network"
      #   model = {
      #     type = "virtio"
      #   }
      #   source = {
      #     network = {
      #       network = "default" # Libvirt default network
      #     }
      #   }
      # },
      {
        model  = { type = "virtio" }
        source = { network = { network = libvirt_network.lab_net.name } } # Private DHCP network - dynamic reference
      }
    ]
  }

  running = true

}

