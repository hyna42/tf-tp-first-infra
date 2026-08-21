# Projet Terraform - Demo KVM/libvirt

## Prérequis

- Terraform ≥ 1.11
- KVM/libvirt opérationnel
- Image Ubuntu 24.04 cloud disponible

### Télécharger l'image si elle est absente

```bash
# Télécharger l'image Ubuntu cloud
mkdir -p ~/images
wget -O ~/images/ubuntu-24.04-cloudimg.img \
  https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

```



### Lancer le projet
```bash
# 1. Télécharge le provider libvirt et configure le backend .terraform/
terraform init

# 2. Vérifie la configuration de l'infrastructure
terraform validate

# 3. Prévisualiser les changements
terraform plan

# 4. Appliquer les changements
terraform apply


```
### Observer le résultat via libvirt
```bash
# 1. Démarrer le moteur
virsh start first-infra-vm # first-infra-vm = nom de la VM
# 2. Vérifer que la VM existe dans Libvirt
virsh list --all # doit afficher 'first-infra-vm' en statut "Running"
# 3. Verifier le volume disque
virsh vol-list default | grep first # disk name = first_infra.qcow2
```

### 
```bash
# 1. Explorer le state (le sate mémorise les ressources crées par Terraform)
terraform state list # doit afficher 'libvirt_domain.vm'  et 'libvirt_volume.disk'
# 2. Pour inspecter une ressource en détail (la vm par exemple)
terraform state show libvirt_domain.vm
```

### Détruire proprement l'infrastructure
```bash
terraform destroy -auto-approve
