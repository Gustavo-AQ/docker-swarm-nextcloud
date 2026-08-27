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

O nó `master` atua como **Manager do Swarm e servidor NFS**, enquanto os serviços da aplicação são distribuídos pelo Docker Swarm entre os nós Workers disponíveis.

O Manager utiliza:

```bash
docker node update --availability drain
```

para impedir a execução dos workloads da aplicação e permanecer dedicado ao gerenciamento do cluster.

## 📁 Estrutura

```text
.
├── .gitattributes
├── .gitignore
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

As máquinas virtuais utilizam **Ubuntu 24.04** através da box `bento/ubuntu-24.04`.

## 🚀 Executando o projeto

### Pré-requisitos

É necessário possuir:

* VirtualBox
* Vagrant
* Git

Clone o repositório e acesse a pasta do projeto:

```bash
git clone https://github.com/Gustavo-AQ/docker-swarm-nextcloud.git
cd docker-swarm-nextcloud
```

### Configure as variáveis de ambiente

A partir da raiz do repositório, entre no diretório da aplicação e crie o arquivo `.env` com base no exemplo:

```bash
cd service
cp .env.example .env
```

Edite o arquivo `.env` e defina as credenciais desejadas.

Depois, volte para a raiz do projeto e acesse o diretório do cluster:

```bash
cd ../cluster-swarm
```

### Inicialize o cluster

Primeiro, inicialize o nó Manager:

```bash
vagrant up master
```

O Manager será responsável por criar o Docker Swarm, configurar o servidor NFS e gerar o comando utilizado pelos Workers para ingressar no cluster.

Depois, inicialize os três Workers:

```bash
vagrant up node01 node02 node03
```

O Vagrant irá:

1. Criar as quatro máquinas virtuais;
2. Instalar o Docker e as dependências necessárias;
3. Criar o Docker Swarm;
4. Configurar o `master` como Manager;
5. Configurar o Manager com disponibilidade `Drain`;
6. Configurar o servidor NFS;
7. Adicionar os demais nós ao cluster como Workers.

## 🔍 Verificando o cluster

Entre no Manager:

```bash
vagrant ssh master
```

Execute:

```bash
docker node ls
```

O resultado deverá mostrar uma estrutura semelhante a:

```text
master    Ready    Drain     Leader
node01    Ready    Active
node02    Ready    Active
node03    Ready    Active
```

## 💾 Armazenamento com NFS

Como Nextcloud e MariaDB precisam persistir dados, o projeto utiliza **NFS** para fornecer armazenamento compartilhado aos nós do cluster.

Os diretórios exportados pelo Manager são:

```text
/srv/nfs/nextcloud
/srv/nfs/mariadb
```

Dessa forma, os serviços continuam tendo acesso aos mesmos dados mesmo quando executados em diferentes Workers.

> A configuração utilizada neste projeto foi criada para fins educacionais e de laboratório. Em ambientes de produção, permissões, redundância, alta disponibilidade e segurança do armazenamento devem receber configurações adicionais.

## 🐳 Implantando a aplicação

Dentro do Manager, acesse o diretório compartilhado da aplicação:

```bash
cd /project/service
```

Carregue as variáveis de ambiente:

```bash
set -a
source .env
set +a
```

Faça o deploy da Stack:

```bash
docker stack deploy \
  -c stack.yml \
  nextcloud
```

Aguarde alguns instantes para que as imagens sejam baixadas e os serviços sejam inicializados.

## 🔍 Verificando os serviços

Acompanhe o estado das tasks:

```bash
docker stack ps nextcloud
```

Verifique os serviços da Stack:

```bash
docker stack services nextcloud
```

Ou visualize todos os serviços do Swarm:

```bash
docker service ls
```

## 🌐 Acessando o Nextcloud

Após a inicialização dos serviços, acesse o Nextcloud através de um dos nós Workers:

```text
http://10.10.10.101:8080
```

Como a porta é publicada através do **Routing Mesh do Docker Swarm**, também é possível utilizar os demais Workers:

```text
http://10.10.10.102:8080
http://10.10.10.103:8080
```

## 🛑 Removendo a Stack

No Manager, execute:

```bash
docker stack rm nextcloud
```

## 🛑 Desligando o ambiente

Saia da VM, caso ainda esteja conectado ao Manager:

```bash
exit
```

No host, dentro do diretório `cluster-swarm`, desligue as máquinas:

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
* Ubuntu 24.04

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
* Routing Mesh;
* gerenciamento de nós;
* isolamento de workloads.

## ⚠️ Observação

O arquivo `worker.sh` pode conter o token utilizado para adicionar Workers ao Docker Swarm.

Neste projeto ele é mantido no repositório por se tratar de um **ambiente educacional e descartável**.

Em ambientes reais ou de produção, tokens e outras credenciais não devem ser armazenados diretamente em repositórios públicos.

---

**Projeto desenvolvido para fins de estudo e prática de Docker Swarm, Vagrant e infraestrutura distribuída.**