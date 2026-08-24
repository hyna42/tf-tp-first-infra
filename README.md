# Projet Terraform - Demo KVM/libvirt

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
## Lifecycle

**1. Initier le projet Terraform** : ```terraform init```
![Configurtion terraform](/assets/init.png)

**2. Vérifier la configuration** : ```terraform validate```
![alt text](/assets/validate.png)

**3. Prévisualiser les changements** : ```terraform plan```
![alt text](/assets/plan1.png)
![alt text](/assets/plan2.png)
**4. Appliquer les changements** : ```terraform apply```
![alt text](/assets/apply1.png)
![alt text](/assets/apply2.png)

**5. Test : afficher les ressources crées**
![alt text](/assets/state_list.png) 
**6. Test: inspecter une ressoure <libvirt_domain.vm>**
![alt text](/assets/state_show.png)

**6. Détruire proprement l'infra** : ```terraform destroy -auto-approve```

## Gérer les VMs avec libvirt 
> Vérifier l'état des VMs : 
```virsh list --all``` 
![alt text](/assets/virsh_list.png) 

***Démarrer la VM** : ```virsh start <name>```
![alt text](/assets/virsh_start.png)

***Démarrer la VM** : ```virsh start ```
![alt text](/assets/virsh_start.png)

*** Vérifier le volume disque***
![alt text](/assets/virsh_vol_list.png)
