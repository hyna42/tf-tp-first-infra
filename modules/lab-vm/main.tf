terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

# --- Volume disk ---
resource "libvirt_volume" "disk" {
  name = "${var.vm_name}.qcow2" # file name in the pool
  pool = var.pool               # target pool (default = /var/lib/libvirt/images)
  target = {
    format = {
      type = "qcow2" # disk format
    }
  }

  create = {
    content = {
      url = var.image_path # copie l'image de base

    }
  }
}

# *********************** cloudinit ***********************
# --- Cloud-init ISO Cloud-Init ---
resource "libvirt_cloudinit_disk" "init" {
  name = local.ci_disk_name
  user_data = templatefile(local.ci_user_data_path, {
    ssh_public_key = trimspace(file(pathexpand(var.path_ssh_public_key)))
    hostname       = var.hostname
    user_name      = var.user_name
  })

  network_config = file("${path.module}/network-config.yml")

  meta_data = yamlencode({
    instance-id    = "${var.vm_name}"
    local-hostname = "${var.hostname}"
  })
}

# --- Cloud-init ISO Volume ---
resource "libvirt_volume" "cloudinit" {
  name = local.ci_volume_name
  pool = var.pool
  create = {
    content = {
      url = libvirt_cloudinit_disk.init.path
    }
  }
}

# *********************** cloudinit ***********************
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
        target    = { dev = "sda", bus = "sata" }
        read_only = true
      }

    ]
    interfaces = [
      {
        model  = { type = "virtio" }
        source = { network = { network = var.network_name } } # Private network
      }
    ]
  }

  running = true

}