# Module `lab-vm`

Module Terraform pour créer une VM libvirt (volume + disque + cloud-init) connectée à un réseau existant.

## Prérequis

- Terraform ≥ 1.0
- Provider dmacvicar/libvirt
- KVM / libvirt opérationnel
- Une image cloud locale (ex: Ubuntu cloud image) disponible sur le disque
- Une clé SSH publique disponible localement

## Description

Ce module provisionne une VM complète : volume disque (qcow2), disque cloud-init (utilisateur + clé SSH), et le domaine libvirt lui-même.
Le module ne crée pas son propre réseau : il **reçoit** le nom d'un réseau existant en entrée (inversion de dépendance), ce qui lui permet d'être connecté à n'importe quel réseau libvirt déjà créé (par exemple via le module `lab-network`).

## Ressources créées

| Ressource | Description |
|---|---|
| `libvirt_volume.disk` | Volume disque principal de la VM (qcow2) |
| `libvirt_cloudinit_disk.init` | Disque cloud-init (utilisateur, clé SSH, hostname) |
| `libvirt_volume.cloudinit` | Volume contenant l'ISO cloud-init |
| `libvirt_domain.vm` | Domaine libvirt (la VM elle-même) |

## Variables (Inputs)

| Nom | Type | Obligatoire | Description |
|---|---|---|---|
| `vm_name` | `string` | ✅ | Nom de la VM dans libvirt |
| `hostname` | `string` | ✅ | Nom d'hôte dans l'OS |
| `user_name` | `string` | ✅ | Nom d'utilisateur créé au boot |
| `memory` | `number` | ✅ | RAM allouée en MiB |
| `vcpu` | `number` | ✅ | Nombre de vCPUs |
| `pool` | `string` | ❌ | Pool libvirt cible (défaut : `default`) |
| `image_path` | `string` | ❌ | Chemin vers l'image cloud de base |
| `path_ssh_public_key` | `string` | ❌ | Chemin vers la clé publique SSH |
| `network_name` | `string` | ✅ | Nom du réseau libvirt existant auquel connecter la VM |

## Sorties (Outputs)

| Nom | Description |
|---|---|
| `vm_name` | Nom de la VM créée |

## Exemple d'utilisation

```hcl
module "lab-vm" {
  source       = "./modules/lab-vm"
  vm_name      = "web01"
  hostname     = "web01"
  user_name    = "ansible"
  memory       = 1024
  vcpu         = 1
  network_name = module.lab-network.network_name
}
```

## Limitation connue

L'adresse IP de la VM est actuellement figée dans `network-config.yml` (pas encore paramétrable). Le support multi-VM avec IP distincte par instance est une évolution prévue (voir CHANGELOG).