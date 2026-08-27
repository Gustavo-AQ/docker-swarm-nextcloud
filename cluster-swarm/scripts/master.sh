#!/bin/bash

set -e

MASTER_IP="10.10.10.100"

echo "======================================"
echo " Configurando Docker Swarm Manager"
echo "======================================"

# Inicializa o Swarm apenas se ainda nao estiver ativo
if ! sudo docker info | grep -q "Swarm: active"; then

    sudo docker swarm init \
        --advertise-addr="$MASTER_IP"

fi


echo "======================================"
echo " Configurando Manager como DRAIN"
echo "======================================"

# O Manager administra o cluster,
# mas nao executa workloads da aplicacao
MANAGER_ID=$(sudo docker node ls \
    --filter role=manager \
    -q | head -n1)

sudo docker node update \
    --availability drain \
    "$MANAGER_ID"


echo "======================================"
echo " Gerando comando dos Workers"
echo "======================================"

WORKER_TOKEN=$(sudo docker swarm join-token -q worker)

cat > /project/cluster-swarm/scripts/worker.sh <<EOF
#!/bin/bash

set -e

docker swarm leave --force 2>/dev/null || true

docker swarm join \\
    --token $WORKER_TOKEN \\
    $MASTER_IP:2377
EOF

chmod +x /project/cluster-swarm/scripts/worker.sh


echo "======================================"
echo " Configurando servidor NFS"
echo "======================================"

sudo apt-get update -y

sudo apt-get install -y \
    nfs-kernel-server


# Diretorios utilizados pelos volumes
sudo mkdir -p /srv/nfs/nextcloud
sudo mkdir -p /srv/nfs/mariadb


# Permissoes simplificadas para laboratorio
sudo chmod -R 777 /srv/nfs


# Configuracao dos compartilhamentos NFS
sudo tee /etc/exports > /dev/null <<EOF
/srv/nfs/nextcloud 10.10.10.0/24(rw,sync,no_subtree_check,no_root_squash)
/srv/nfs/mariadb 10.10.10.0/24(rw,sync,no_subtree_check,no_root_squash)
EOF


# Atualiza os exports
sudo exportfs -rav

# Habilita e reinicia o servidor NFS
sudo systemctl enable nfs-kernel-server
sudo systemctl restart nfs-kernel-server


echo "======================================"
echo " Manager configurado com sucesso!"
echo "======================================"

sudo docker node ls