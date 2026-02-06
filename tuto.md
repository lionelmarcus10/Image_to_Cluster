- En cours de construction
- Automatiser le cleanup de l'infra ( stop all services / deployment)
- Destroy k3d nodes


-------


## Install dependencies :

### k3d

```bash
k3d cluster create lab \
  --servers 1 \
  --agents 2
```

### Packer
```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer
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
kubectl apply deployment.yml
# Wait until deployment
kubectl wait --for=condition=available deployment/lionel-site-deployment
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
sleep 10
# Forward port
kubectl port-forward --pod-running-timeout=60s svc/lionel-service 8080:80  >/tmp/website.log 2>&1 &
```