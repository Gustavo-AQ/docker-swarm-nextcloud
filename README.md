# 🐳 Docker Swarm + Nextcloud

Projeto desenvolvido durante a **Formação Docker Fundamentals**, com o objetivo de colocar em prática conceitos de criação e gerenciamento de um cluster utilizando **Docker Swarm e Vagrant**.

Como evolução de um projeto anterior utilizando Docker Compose, neste laboratório uma aplicação **Nextcloud com MariaDB e Redis** é implantada em um cluster composto por quatro máquinas virtuais.

## 🏗️ Arquitetura

O ambiente é composto por:

* **1 Manager**
* **3 Workers**
* **Docker Swarm**
* **NFS**
* **Nextcloud**
* **MariaDB**
* **Redis**

```text
                       Docker Swarm
                            │
              ┌─────────────┴─────────────┐
              │                           │
            Manager                     Workers
        10.10.10.100          ┌───────────┼───────────┐
              │               │           │           │
              │             node01      node02      node03
              │             .101        .102        .103
              │
        Swarm Manager
          + NFS Server
              │
       availability: drain
              │
              └──────────── NFS ─────────────┐
                                             │
                                ┌────────────┴────────────┐
                                │                         │
                           Nextcloud                  MariaDB
                             Data                       Data
```

O nó `master` atua como **Manager do Swarm e servidor NFS**, enquanto os serviços da aplicação são executados pelos três workers.

O manager utiliza:

```bash
docker node update --availability drain
```

para impedir a execução dos workloads da aplicação e permanecer dedicado ao gerenciamento do cluster.

## 📁 Estrutura

```text
.
├── README.md
├── service
│   ├── stack.yml
│   └── .env.example
│
└── cluster-swarm
    ├── Vagrantfile
    └── scripts
        ├── docker.sh
        ├── master.sh
        └── worker.sh
```

## 🖥️ Máquinas

| Máquina | IP             | Função              |
| ------- | -------------- | ------------------- |
| master  | `10.10.10.100` | Swarm Manager + NFS |
| node01  | `10.10.10.101` | Worker              |
| node02  | `10.10.10.102` | Worker              |
| node03  | `10.10.10.103` | Worker              |

## 🚀 Executando o projeto

### Pré-requisitos

É necessário possuir:

* VirtualBox
* Vagrant
* Git

Clone o repositório:

```bash
git clone <URL_DO_REPOSITORIO>
```

Entre no diretório do cluster:

```bash
cd cluster-swarm
```

Suba as máquinas:

```bash
vagrant up
```

O Vagrant irá:

1. Criar as quatro máquinas virtuais;
2. Instalar o Docker;
3. Criar o Docker Swarm;
4. Configurar o `master` como Manager;
5. Adicionar os demais nós como Workers;
6. Configurar o servidor NFS.

## 🔍 Verificando o cluster

Entre no manager:

```bash
vagrant ssh master
```

Execute:

```bash
docker node ls
```

O resultado deverá mostrar:

```text
master    Ready    Drain     Leader
node01    Ready    Active
node02    Ready    Active
node03    Ready    Active
```

## 💾 Armazenamento com NFS

Como Nextcloud e MariaDB precisam persistir dados, o projeto utiliza **NFS** para fornecer armazenamento compartilhado aos nós do cluster.

Os diretórios exportados pelo manager são:

```text
/srv/nfs/nextcloud
/srv/nfs/mariadb
```

Dessa forma, os serviços continuam tendo acesso aos mesmos dados mesmo quando executados em diferentes workers.

> A configuração utilizada neste projeto foi criada para fins educacionais e de laboratório. Em ambientes de produção, permissões, redundância, alta disponibilidade e segurança do armazenamento devem receber configurações adicionais.

## 🐳 Implantando a aplicação

Crie o arquivo `.env`:

```bash
cd service

cp .env.example .env
```

Edite as credenciais conforme necessário.

Depois entre no manager:

```bash
cd cluster-swarm

vagrant ssh master
```

Carregue as variáveis:

```bash
cd /project/service

set -a
source .env
set +a
```

Faça o deploy:

```bash
docker stack deploy \
  -c stack.yml \
  nextcloud
```

## 🔍 Verificando os serviços

```bash
docker stack services nextcloud
```

Ou:

```bash
docker service ls
```

Para visualizar onde cada task está sendo executada:

```bash
docker stack ps nextcloud
```

## 🌐 Acessando o Nextcloud

Após a inicialização dos serviços, acesse:

```text
http://10.10.10.101:8080
```

Também é possível utilizar outro nó do cluster devido ao **routing mesh do Docker Swarm**.

## 🛑 Removendo a Stack

```bash
docker stack rm nextcloud
```

## 🛑 Desligando o ambiente

No host:

```bash
vagrant halt
```

Para destruir todas as máquinas virtuais:

```bash
vagrant destroy -f
```

## 🛠️ Tecnologias

* Docker
* Docker Swarm
* Docker Stack
* Vagrant
* VirtualBox
* NFS
* Nextcloud
* MariaDB
* Redis
* Linux

## 📚 Conceitos praticados

Durante o projeto foram aplicados conceitos como:

* criação automatizada de máquinas virtuais;
* provisionamento com Vagrant;
* Docker Swarm;
* arquitetura Manager/Worker;
* Docker Stack;
* redes Overlay;
* serviços distribuídos;
* armazenamento compartilhado com NFS;
* persistência de dados;
* routing mesh;
* gerenciamento de nós;
* isolamento de workloads.

## ⚠️ Observação

O arquivo `worker.sh` pode conter o token utilizado para adicionar workers ao Docker Swarm.

Neste projeto ele é mantido no repositório por se tratar de um **ambiente educacional e descartável**.

Em ambientes reais ou de produção, tokens e outras credenciais não devem ser armazenados diretamente em repositórios públicos.

---

**Projeto desenvolvido para fins de estudo e prática de Docker Swarm, Vagrant e infraestrutura distribuída.**