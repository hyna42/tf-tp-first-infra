
# --- DHCP Network ---
resource "libvirt_network" "lab_net" {
  name      = local.network_name
  autostart = true
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
        source = { network = { network = libvirt_network.lab_net.name } } # Private network
      }
    ]
  }

  running = true

}

# --- Iventaire Ansible ---
resource "ansible_group" "webservers" {
  name = "webservers" # Nom du groupe dans l'inventaire
}

resource "ansible_host" "host" {
  name   = "web0.lab"                      # Nom de l'hôte
  groups = [ansible_group.webservers.name] # Appartenance au groupe

  variables = {
    ansible_host                 = "10.20.0.42"  # IP fixe de la VM
    ansible_user                 = var.user_name # user SSH
    ansible_ssh_private_key_file = pathexpand(var.path_ssh_private_key)
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no"
    ansible_python_interpreter   = "/usr/bin/python3.12"
  }
}
# ssh -o StrictHostKeyChecking=no -i /home/hyna/.ssh/id_ed25519 ansible@10.20.0.42
