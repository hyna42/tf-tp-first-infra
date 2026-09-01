variable "cidr" {
  description = "CIDR du réseau privé"
  type        = string
  nullable    = false
}

variable "network_name" {
  description = "Nom du réseau privé"
  type        = string
  nullable    = false
}
