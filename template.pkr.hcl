packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "nginx_k3d" {
  image  = "nginx:alpine"
  commit = true
  changes = [
    "EXPOSE 80",
    "LABEL maintainer='Lionel'"
    # On laisse l'ENTRYPOINT par défaut de l'image nginx:alpine
  ]
}

build {
  name    = "k3d-builder"
  sources = ["source.docker.nginx_k3d"]

  # Copie du fichier HTML vers le répertoire Nginx
  provisioner "file" {
    source      = "index.html"
    destination = "/usr/share/nginx/html/index.html"
  }

  provisioner "shell" {
    inline = ["echo 'Build k3d of Lionel terminé avec succès !'"]
  }

  post-processor "docker-tag" {
    repository = "k3d-lionel-site"
    tags       = ["latest"]
  }
}