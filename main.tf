
# --- DHCP Network ---
resource "libvirt_network" "lab_net" {
  name      = local.network_name
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
  name = local.disk_name # file name in the pool
  pool = var.pool        # target pool (default = /var/lib/libvirt/images)
  target = {
    format = {
      type = "qcow2" # disk format
    }
  }

  create = {
    content = {
      url = var.image_path

    }
  }
}

# --- Cloud-init : génération de l'ISO Cloud-Init (mémoire vive) ---
resource "libvirt_cloudinit_disk" "init" {
  name = local.ci_disk_name
  user_data = templatefile(local.ci_user_data_path, {
    ssh_key  = trimspace(file(pathexpand(var.ssh_key_path)))
    hostname = var.hostname, #variable passé au template
  })
  meta_data = yamlencode({
    instance-id    = "${var.vm_name}"
    local-hostname = "${var.hostname}"
  })
}

# --- Cloud-init : création du volume physique contenant l'ISO ---
resource "libvirt_volume" "cloudinit" {
  name = local.ci_volume_name
  pool = var.pool
  create = {
    content = {
      url = libvirt_cloudinit_disk.init.path
    }
  }
}

# --- Domaine (VM) ---
resource "libvirt_domain" "vm" {
  name        = var.vm_name # VM name in libvirt
  type        = "kvm"       # Hyperviseur (KVM)
  memory      = var.memory
  memory_unit = "MiB"
  vcpu        = var.vcpu # vCPUs number


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

