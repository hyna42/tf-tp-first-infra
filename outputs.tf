output "vm" {
  value       = libvirt_domain.vm.name
  description = "Nom de la VM"
}
output "network_name" {
  value       = libvirt_network.lab_net.name
  description = "Nom de la VM connecté au réseau"
}

output "ansible_group" {
  description = "Groupe Ansible"
  value       = ansible_group.webservers.name
}

output "ansible_host" {
  description = "Hôte Ansible"
  value       = ansible_host.host.name
}
