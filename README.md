- En cours de construction
- Automatiser le cleanup de l'infra ( stop all services / deployment)
- Destroy k3d nodes


-------

## Automatic setup : 

### Déploiement de l’infrastructure Web avec k3d, Packer et Ansible

Ce guide explique comment installer les dépendances, déployer, mettre à jour et supprimer votre site web sur un cluster k3d local.

---

### 1. Installation des dépendances et création du cluster

Pour installer **k3d**, **Packer**, **Ansible** et créer le cluster `lab` (si ce n’est pas déjà fait) :

```bash
make setup
```

> Cette commande est **idempotente**, elle n’installera rien si les outils ou le cluster existent déjà.

---

### 2. Déploiement initial du site

Pour déployer le site web pour la première fois :

```bash
make deploy
```

- Reconstruit l’image Packer  
- Importe l’image dans k3d  
- Déploie le site dans Kubernetes  
- Active le port-forward pour accéder au site sur [http://localhost:8080](http://localhost:8080)

---

### 3. Mise à jour du site

Si vous modifiez le site (HTML, assets…) et que vous voulez mettre à jour le déploiement :

```bash
make update
```

- Reconstruit l’image Packer  
- Importe l’image dans k3d  
- Redéploie le site existant  
- Redémarre le port-forward

---

### 4. Suppression de l’infrastructure

Pour stopper les services, supprimer le déploiement et détruire le cluster k3d :

```bash
make destroy
```

- Arrête le port-forward  
- Supprime le déploiement Kubernetes  
- Supprime le cluster k3d `lab`

---

### 5. Accès au site

Après un déploiement ou une mise à jour, le site est accessible en local sur :  

```
http://localhost:8080
```

---

Toutes les commandes sont **centralisées via Make** et utilisent Ansible pour le déploiement et la destruction.



---

> For manual usage you could follow those two sections :

## Install dependencies :

### k3d

```bash
# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
# Install k3d cluster
k3d cluster create lab \
  --servers 1 \
    --agents 2
```

### Packer
```bash
sudo apt update
sudo apt install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install packer
```
### Ansible

```bash
pipx install --include-deps ansible
```

## Step 2.1 Create web app oci with packer

```bash
## Init packer and download deps
packer init template.pkr.hcl
# Build
packer build template.pkr.hcl
```

## Step 2.2 Deploy the website (first deploy)

```bash
# Import the image
k3d image import k3d-lionel-site:latest -c lab
# Deploy component
kubectl apply -f deployment.yml
# Wait until deployment
kubectl wait --for=condition=available deployment/lionel-site-deployment
sleep 10
# Forward port
kubectl port-forward svc/lionel-service 8080:80 >/tmp/website.log 2>&1 &
```

## Step 2.3 Deploy the website after an update of the HTML page

```bash
# Build
packer build template.pkr.hcl
# Import the image
k3d image import k3d-lionel-site:latest -c lab
# Force restart
kubectl rollout restart deployment/lionel-site-deployment
# Wait until
kubectl wait --for=condition=available deployment/lionel-site-deployment
pkill -f "kubectl port-forward.*8080:80"
sleep 10
# Forward port
kubectl port-forward --pod-running-timeout=60s svc/lionel-service 8080:80  >/tmp/website.log 2>&1 &
```