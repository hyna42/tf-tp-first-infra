# Infra Terraform x KVM/libvirt

## Prérequis

- Terraform ≥ 1.11
- KVM/libvirt opérationnel
- Image Ubuntu 24.04 cloud disponible

### Télécharger l'image si elle est absente

```bash
# Télécharger l'image Ubuntu cloud
mkdir -p ~/var/lib/libvirt/images/base
wget -O ~/var/lib/libvirt/images/base/noble-server-cloudimg-amd64.img \
  https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

```

## Structure du projet

```text
tp-first-infra/
├── versions.tf       # Provider et version Terraform
├── variables.tf      # Déclarations des variables d'entrée
├── locals.tf         # Valeurs calculées (vm_name, hostname...)
├── main.tf           # Ressources libvirt (network, volume, cloudinit, domain)
├── outputs.tf         # Ce que Terraform affiche après apply
├── terraform.tfvars   # Valeurs concrètes (surchargent les defaults)
├── Makefile           # Raccourcis pour les commandes courantes
└── cloud-init/
    └── user-data.yaml  # Configuration cloud-init (hostname, user, clé SSH)
```

## Quick Start (si vous êtes pressé)

Un `Makefile` regroupe les commandes du cycle de vie courant :

```makefile
validate:
	@terraform validate

plan:
	@terraform plan

apply:
	@terraform apply -auto-approve

destroy:
	@terraform destroy -auto-approve
```

```bash
make validate   # équivalent : terraform validate
make plan       # équivalent : terraform plan
make apply      # équivalent : terraform apply -auto-approve
make destroy    # équivalent : terraform destroy -auto-approve
```

> Pratique une fois la logique de chaque commande bien comprise (voir la partie Lifecycle ci-dessous) — l'objectif ici n'est pas de mettre `make` en avant, juste de gagner du temps au quotidien.

## Lifecycle détaillé Terraform

**_1. Initier le projet Terraform_** : ```terraform init```

![Configurtion terraform](/assets/init.png)

**_2. Vérifier la configuration_** : ```terraform validate```

![alt text](/assets/validate.png)

**_3. Prévisualiser les changements_** : ```terraform plan```

![alt text](/assets/plan1.png)

![alt text](/assets/plan2.png)

**_4. Appliquer les changements_** : ```terraform apply```

![alt text](/assets/apply1.png)

![alt text](/assets/apply2.png)

**_5. Test : afficher les ressources crées_**

![alt text](/assets/state_list.png) 

**_6. Test: inspecter une ressoure <libvirt_domain.vm>_**

![alt text](/assets/state_show.png)

**_6. Détruire proprement l'infra_** : ```terraform destroy -auto-approve```

## Gérer les VMs avec libvirt 
> Vérifier l'état des VMs : 
```virsh list --all``` 

![alt text](/assets/virsh_list.png) 

_Démarrer la VM_ : ```virsh start <name>```

![alt text](/assets/virsh_start.png)

### Domaine (VM)
_Informations détaillées_ : ```virsh dominfo <name>```

![alt text](/assets/virsh_start.png)

_Voir les Interfaces réseau_: ```virsh domiflist <name>```

![alt text](/assets/virsh_domiflist.png)

_Informations détaillées de la VM_: ```virsh dominfo <name>```

![alt text](/assets/dominfo.png)

### Pools Volume
_Vérifier le volume_

![alt text](/assets/virsh_vol_list.png)

### Network
_Vérifier que le réseau privé existe dans libvirt_ : ```virsh net-list --all```

![alt text](/assets/virsh_net-list-all.png)

_Afficher la configuration complète du réseau_ : ```virsh net-dumpxml <name>```

![alt text](/assets/virsh_net-dumpxml.png)

_Afficher le bail DHCP pour récupérer l'IP_ : ```virsh net-dhcp-leases <network_name>```

![alt text](/assets/found-ip.png)

_Connexion SSH à la VM_: ```ssh ubuntu@<IP>```

![alt text](/assets/ssh-connect.png)

### Testes de commandes sur la vm
![alt text](/assets/ssh-connect-test1.png)

![alt text](/assets/ssh-connect-test2.png)