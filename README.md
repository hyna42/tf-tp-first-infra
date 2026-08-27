# Infra Terraform x KVM/libvirt x Ansible

## Prérequis
<<<<<<< HEAD
- Terraform ≥ 1.11
=======

- Terraform ≥ 1.15
>>>>>>> tf-ansible
- KVM/libvirt opérationnel
- Image Ubuntu 24.04 cloud disponible

## Structure du projet

```text
tp-first-infra/
├── versions.tf              # Providers requis
├── variables.tf             # Variables d'entrée
├── locals.tf                # Valeurs calculées
├── main.tf                  # VM + Cloudinit + Inventaire ansible
├── outputs.tf               # Sorties
├── terraform.tfvars         # Valeurs concrètes
├── Makefile                 # Raccourcis commandes courantes
├── cloud-init.yml           # Configuration premier boot
├── network-config.yml       # Réseau statique pour cloud-init
├── inventory.yml            # Inventaire Ansible
├── playbook/
│   ├── nginx.yml            # Playbook Ansible - install nginx
│   └── uninstalled_nginx.yml # Playbook Ansible - désinstalle nginx
└── roles/
    ├── nginx/               # Rôle Ansible - install nginx
    └── nginx-uninstall/     # Rôle Ansible - désinstalle nginx
```


## Commandes Makefile

### Terraform

| Commande | Description |
|----------|-------------|
| `make fmt` | Formate les fichiers Terraform |
| `make validate` | Valide la configuration Terraform |
| `make plan` | Affiche le plan d'exécution Terraform |
| `make apply` | Applique la configuration Terraform (auto-approve) |
| `make destroy` | Détruit l'infrastructure Terraform (auto-approve) |

### Ansible

| Commande | Description |
|----------|-------------|
| `make list` | Affiche l'inventaire Ansible |
| `make ping` | Teste la connectivité avec tous les hôtes |
| `make nginx-install` | Installe et configure nginx sur les serveurs web |
| `make nginx-uninstall` | Désinstalle nginx des serveurs web |

### Exemples d'utilisation

```bash
# Terraform
make fmt        # Formate les fichiers Terraform
make validate   # Valide la configuration Terraform
make plan       # Affiche le plan d'exécution
make apply      # Applique la configuration (auto-approve)
make destroy    # Détruit l'infrastructure (auto-approve)

# Ansible
make list       # Affiche l'inventaire Ansible
make ping       # Teste la connectivité SSH avec les hôtes
make nginx-install    # Installe nginx sur les serveurs
make nginx-uninstall  # Désinstalle nginx des serveurs
```

> Pratique une fois la logique de chaque commande bien comprise (voir la partie Lifecycle ci-dessous) — l'objectif ici n'est pas de mettre `make` en avant, juste de gagner du temps au quotidien.

## Lifecycle détaillé

> Se reporter à la branche  **_[minimum-vm](https://github.com/hyna42/tf-tp-first-infra/tree/minim-vm)_**  pour la mise en place du VM + Network + Cloudinit, ensuite tester que les phases Terraform [init + validate + plan + appy ] fonctionnent

**_1. [Re]appliquer les changements_** : ```terraform apply```

![alt text](/assets/apply_netstart.png)
**Activer le réseau si state=inactve** : ``virsh net-start lab-net``


**_2. Tester la connexon ssh_** : ```ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 <user_name>@<IP> "hostname"```

**_3. Vérifier l'inventaire dynamique_** : ```ansible-inventory --list```
![alt text](/assets/inventory_list.png)

**_4. Tester la connectivité_** : ```ansible all -m ansible.builtin.ping```
![alt text](/assets/ping.png)

**_5. Installer le service nginx + Vérifier l'idempotence_** : ```ansible-playbook playbook/nginx.yml```
![alt text](/assets/nginx-install.png)

**_6. Desintaller nginx + Vérifier l'idempotence_** : ```ansible-playbook playbook/uninstalled_nginx.yml```
![alt text](/assets/nginx-uninstall.png)

<<<<<<< HEAD
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
=======
>>>>>>> tf-ansible
