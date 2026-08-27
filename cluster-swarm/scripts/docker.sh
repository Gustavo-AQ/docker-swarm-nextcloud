#!/bin/bash

set -e

echo "======================================"
echo " Instalando Docker e dependencias"
echo "======================================"

sudo apt-get update -y

# Cliente NFS e utilitarios
sudo apt-get install -y \
    nfs-common \
    curl

# Instala Docker
curl -fsSL https://get.docker.com | sudo bash

# Permite que o usuario vagrant utilize Docker
sudo usermod -aG docker vagrant

# Habilita e inicia o Docker
sudo systemctl enable docker
sudo systemctl start docker

echo "======================================"
echo " Docker instalado com sucesso!"
echo "======================================"