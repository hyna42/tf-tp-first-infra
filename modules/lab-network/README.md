# Module `lab-network`

Module Terraform pour créer un réseau NAT libvirt avec DHCP.

## Prérequis
- Terraform ≥ 1.0
- Provider dmacvicar/libvirt
- KVM / libvirt opérationnel

## Description

Ce module provisionne un réseau privé libvirt en mode **NAT** avec une plage **DHCP** automatique.  
Il est conçu pour être partagé par plusieurs VMs au sein d'un même lab.

## Ressources créées

| Ressource | Description |
|---|---|
| `libvirt_network.this` | Réseau NAT libvirt avec DHCP |

## Variables (Inputs)

| Nom | Type | Obligatoire | Description |
|---|---|---|---|
| `network_name` | `string` | ✅ | Nom du réseau libvirt |
| `cidr` | `string` | ✅ | CIDR du réseau (ex: `10.20.0.0/24`) |

## Sorties (Outputs)

| Nom | Description |
|---|---|
| `network_name` | Nom du réseau créé |
| `network_id` | ID du réseau créé |

## Exemple d'utilisation

```hcl
module "lab-network" {
  source       = "./modules/lab-network"
  network_name = "lab-net"
  cidr         = "10.20.0.0/24"
}

# Plage DHCP Calculée automatiquement à partir du CIDR
# Début : 100ème hôte du réseau (10.20.0.100)
# Fin : 200ème hôte du réseau (10.20.0.200)
# Passerelle : 1er hôte du réseau (10.20.0.1)

```
