```markdown
# Infra Terraform x KVM/libvirt x Ansible

## Prérequis

- Terraform ≥ 1.15
- KVM/libvirt opérationnel
- Image Ubuntu 24.04 cloud disponible

## Structure du projet

```text
tp-first-infra/
├── versions.tf                    # Providers requis
├── variables.tf                   # Variables d'entrée
├── locals.tf                      # Valeurs calculées
├── main.tf                        # Appels de modules + Inventaire ansible
├── outputs.tf                     # Sorties
├── terraform.tfvars               # Valeurs concrètes
├── Makefile                       # Raccourcis commandes courantes
├── modules/
│   ├── lab-network/                # Module : réseau NAT libvirt + DHCP
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── lab-vm/                     # Module : VM + volume + cloud-init
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── cloud-init.yml          # Configuration premier boot
│       ├── network-config.yml      # Réseau statique pour cloud-init
│       └── README.md
├── inventory.yml                  # Inventaire Ansible
├── playbook/
│   ├── nginx.yml                  # Playbook Ansible - install nginx
│   └── uninstalled_nginx.yml      # Playbook Ansible - désinstalle nginx
└── roles/
    ├── nginx/                      # Rôle Ansible - install nginx
    └── nginx-uninstall/            # Rôle Ansible - désinstalle nginx
```

## Commandes Makefile

### Terraform

| Commande | Description |
|----------|-------------|
| `make init` | Téléchager les providers et modules, initialiser le backend terrafom |
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

## Architecture modulaire

Depuis la v2.0.0, l'infrastructure est découpée en deux modules réutilisables :

- **`modules/lab-network`** : crée le réseau NAT libvirt avec DHCP, à partir d'un simple CIDR.
- **`modules/lab-vm`** : crée une VM (volume + cloud-init + domaine), et **reçoit** le nom du réseau en entrée plutôt que de le créer lui-même (inversion de dépendance).

Voir le README de chaque module pour le détail des variables et outputs.

## Lifecycle détaillé

> Se reporter à la branche **_[minimum-vm](https://github.com/hyna42/tf-tp-first-infra/tree/minim-vm)_** pour la mise en place du VM + Network + Cloudinit, ensuite tester que les phases Terraform [init + validate + plan + apply] fonctionnent

**_1. [Re]appliquer les changements_** : ```terraform apply```

![alt text](/assets/apply_netstart.png)

**Activer le réseau si state=inactive** : ``virsh net-start lab-net``

**_2. Tester la connexion ssh_** : ```ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 <user_name>@<IP> "hostname"```

**_3. Vérifier l'inventaire dynamique_** : ```ansible-inventory --list```

![alt text](/assets/inventory_list.png)

**_4. Tester la connectivité_** : ```ansible all -m ansible.builtin.ping```

![alt text](/assets/ping.png)

**_5. Installer le service nginx + Vérifier l'idempotence_** : ```ansible-playbook playbook/nginx.yml```

![alt text](/assets/nginx-install.png)

**_6. Désinstaller nginx + Vérifier l'idempotence_** : ```ansible-playbook playbook/uninstalled_nginx.yml```

![alt text](/assets/nginx-uninstall.png)

## À venir / Roadmap

- [x] Extraction en modules réutilisables (`lab-network`, `lab-vm`)
- [ ] **Multi-VM avec IP distincte par instance** : templatiser `network-config.yml` en `.tpl` via `templatefile()`, passer l'IP en variable au module `lab-vm`, et faire un `for_each` correspondant sur `ansible_host` pour générer l'inventaire dynamique
- [ ] **Séparer le dépôt Ansible du dépôt Terraform** : nécessite de faire lire l'inventaire dynamique depuis un state distant (`terraform_remote_state` ou backend partagé) plutôt qu'un state local voisin
- [ ] Lancer l'exécution du playbook Ansible directement depuis le plan Terraform (post-apply)
```