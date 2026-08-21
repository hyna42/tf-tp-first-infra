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


