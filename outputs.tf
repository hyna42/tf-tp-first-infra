output "ansible_group" {
  description = "Groupe Ansible"
  value       = ansible_group.webservers.name
}

output "ansible_host" {
  description = "Hôte Ansible"
  value       = ansible_host.host.name
}

output "network_name" {
  value       = module.lab-network.network_name
  description = "Nom de la VM connecté au réseau"
}

output "vm" {
  value       = module.lab-vm.vm_name
  description = "Nom de la VM"
}

