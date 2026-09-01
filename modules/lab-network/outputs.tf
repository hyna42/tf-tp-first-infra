output "network_name" {
  description = "Nom du réseau privé"
  value       = libvirt_network.this.name
}

output "network_id" {
  description = "ID du réseau privé"
  value       = libvirt_network.this.id
}

