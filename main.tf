# --- Volume disk ---
resource "libvirt_volume" "disk" {
  name = "first_infra.qcow2" # file name in the pool
  pool = "default"           # target pool (default = /var/lib/libvirt/images)
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

# --- Domaine (VM) ---
resource "libvirt_domain" "vm" {
  name        = "first-infra-vm" # VM name in libvirt
  type        = "kvm"            # Hyperviseur (KVM)
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
      }
    ]
    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = "default" # Libvirt network by default
          }
        }
      }
    ]
  }
}
