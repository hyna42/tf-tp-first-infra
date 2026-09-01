variable "hostname" {
  description = "Nom dans l'OS"
  type        = string
  nullable    = false
}

variable "image_path" {
  description = "Chemin vers l'image cloud de base"
  type        = string
  default     = "/var/lib/libvirt/images/base/noble-server-cloudimg-amd64.img"
}
variable "memory" {
  description = "RAM alloué en MiB"
  type        = number
  nullable    = false
  # default     = 1024 #1Go
  validation {
    condition     = var.memory >= 256 && var.memory <= 16384
    error_message = "La mémoire doit être comprise entre 256 et 16384"
  }
}

variable "network_name" {
  description = "Nom du réseau"
  type        = string
  nullable    = false
}


variable "path_ssh_public_key" {
  description = "Chemin vers la clé publique SSH (pour déposer la clé publique dans authorized_keys de la VM au boot)"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}


variable "pool" {
  description = "Pool libvirt cible"
  type        = string
  default     = "default"
}

variable "user_name" {
  description = "Le nom d'utilisateur"
  type        = string
  nullable    = false
}

variable "vcpu" {
  description = "Nombre de vCPUs"
  type        = number
  nullable    = false
  # default     = 1
}

variable "vm_name" {
  description = "Nom de la VM"
  type        = string
  nullable    = false
  #   default     = "lab-vm"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.vm_name))
    error_message = "Le nom de VM ne peut contenenir que des minuscules, des chiffres, des lettres et des tirets."
  }
}








