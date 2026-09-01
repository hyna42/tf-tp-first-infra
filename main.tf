module "lab-network" {
  source       = "./modules/lab-network"
  cidr         = "10.20.0.0/24"
  network_name = "lab-net"
}

# variable "vms" {
#   type = map(object({
#     name         = string
#     hostname     = string
#     memory       = number
#     vcpu         = number
#     network_name = string
#   }))

#   default = {
#     web01 = {
#       name="terraform-lab-01",
#       hostname="web01",
#       memory=1024,
#       vcpu=1
#     },

#     web02 = {
#       name="terraform-lab-02",
#       hostname="web02",
#       memory=512,
#       vcpu=1
#     }
#   }
  
# }

module "lab-vm" {
  source = "./modules/lab-vm"

  # pool, image_path , path_ssh_public_key ==> default             = default
  vm_name = var.vm_name
  hostname  = var.hostname
  memory       = var.memory
  vcpu         = var.vcpu
  user_name = var.user_name
  network_name = module.lab-network.network_name
  depends_on = [module.lab-network]
}

# --- Iventaire Ansible ---
resource "ansible_group" "webservers" {
  name = "webservers" # Nom du groupe dans l'inventaire
}

resource "ansible_host" "host" {
  name   = "${var.hostname}.lab"           # Nom de l'hôte
  groups = [ansible_group.webservers.name] # Appartenance au groupe

  variables = {
    ansible_host                 = "10.20.0.42"  # IP fixe de la VM
    ansible_user                 = var.user_name # user SSH
    ansible_ssh_private_key_file = pathexpand(var.path_ssh_private_key)
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no"
    ansible_python_interpreter   = "/usr/bin/python3.12"
  }
}
# Historiques des renommages
moved {
  from = libvirt_network.lab_net
  to   = module.lab-network.libvirt_network.this
}

moved {
  from = libvirt_cloudinit_disk.init
  to   = module.lab-vm.libvirt_cloudinit_disk.init
}

moved {
  from = libvirt_domain.vm
  to   = module.lab-vm.libvirt_domain.vm
}

moved {
  from = libvirt_volume.cloudinit
  to   = module.lab-vm.libvirt_volume.cloudinit
}

moved {
  from = libvirt_volume.disk
  to   = module.lab-vm.libvirt_volume.disk
}
