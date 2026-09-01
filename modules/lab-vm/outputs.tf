output "vm_name" {
  description = "Nom de la VM"
  type        = string
  value       = libvirt_domain.vm.name
}