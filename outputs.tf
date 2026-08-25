output "vm" {
  value       = libvirt_domain.vm.name
  description = "Nom de la VM"
}
output "network_name" {
  value       = libvirt_network.lab_net.name
  description = "Nom de la VM connecté au réseau"
}
