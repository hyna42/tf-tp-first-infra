locals {
  disk_name         = "${var.vm_name}.qcow2"
  network_name      = "lab-net"
  ci_user_data_path = "${path.module}/cloud-init.yml"
  ci_disk_name      = "${var.vm_name}-init.iso"
  ci_volume_name    = "${var.vm_name}-cloudinit-config"

}
