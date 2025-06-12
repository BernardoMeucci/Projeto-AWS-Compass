# Implantação de WordPress na AWS: Arquitetura Escalável e de Alta Disponibilidade

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white) ![WordPress](https://img.shields.io/badge/WordPress-%23117AC9.svg?style=for-the-badge&logo=WordPress&logoColor=white) ![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

<br>

> Este projeto detalha a implementação de uma infraestrutura completa para **WordPress na AWS**, seguindo as melhores práticas de nuvem (*Cloud Best Practices*). A arquitetura foi desenhada para ser segura, resiliente a falhas, escalável e totalmente automatizada.

---

### 🗺️ Tabela de Conteúdos
1.  [Objetivo do Projeto](#-objetivo-do-projeto)
2.  [Arquitetura Final da Solução](#️-arquitetura-final-da-solução)
3.  [Estrutura de Arquivos do Repositório](#-estrutura-de-arquivos-do-repositório)
4.  [Serviços AWS Utilizados](#️-serviços-aws-utilizados)
5.  [Detalhes da Infraestrutura](#️-detalhes-da-infraestrutura)
6.  [Arquivos de Configuração e Automação](#-arquivos-de-configuração-e-automação)
7.  [Resultado Final](#-resultado-final)

---

## 🎯 Objetivo do Projeto

O objetivo central foi projetar e implantar uma solução de nível profissional para WordPress, conforme a topologia e os requisitos especificados, consolidando conhecimentos em:
- **Segurança:** Isolar recursos em redes privadas e aplicar o princípio do menor privilégio.
- **Alta Disponibilidade:** Garantir que a aplicação se mantenha operacional mesmo com falhas em componentes individuais.
- **Escalabilidade:** Permitir que a infraestrutura se ajuste dinamicamente às variações de tráfego.
- **Automação (IaC):** Provisionar e configurar o ambiente de forma automática e reprodutível.

<br>

## 🏗️ Arquitetura Final da Solução

A arquitetura foi planejada para desacoplar as camadas da aplicação, utilizando serviços gerenciados da AWS para maximizar a eficiência operacional e a segurança.

<div align="center">
  <img src="imagens/arquitetura-final.png" alt="Diagrama da Arquitetura Final na AWS" width="800"/>
  <p><em>Diagrama da arquitetura de alta disponibilidade para WordPress.</em></p>
</div>

---

## 📂 Estrutura de Arquivos do Repositório

Para uma melhor organização, o código de automação foi separado em arquivos distintos com responsabilidades claras.

```
.
├── imagens/
│   ├── arquitetura-final.png
│   └── ... (outros screenshots)
├── scripts/
│   └── user_data.sh
├── docker-compose.yml
└── README.md
```

- **`imagens/`**: Contém todos os screenshots e diagramas da documentação.
- **`scripts/user_data.sh`**: Script BASH principal que é executado nas instâncias EC2 para configurar todo o ambiente.
- **`docker-compose.yml`**: Arquivo de configuração que define o serviço do container WordPress.

<br>

## 🛠️ Serviços AWS Utilizados

A tabela abaixo resume os principais serviços AWS e suas finalidades no projeto.

| Serviço | Finalidade no Projeto |
| :--- | :--- |
| **Amazon VPC** | Criação de uma rede virtual isolada para hospedar todos os recursos. |
| **Amazon EC2** | Servidores virtuais que executam a aplicação WordPress em containers Docker. |
| **Auto Scaling Group** | Automatiza a criação, recuperação e escalabilidade da frota de instâncias. |
| **Application Load Balancer** | Ponto de entrada que distribui o tráfego HTTP de forma balanceada e segura. |
| **Amazon RDS** | Fornece um banco de dados MySQL gerenciado (Single-AZ, conforme requisito do ambiente). |
| **Amazon EFS** | Oferece um sistema de arquivos de rede compartilhado e persistente para a pasta `wp-content`. |
| **AWS IAM** | Gerencia permissões de forma granular e segura para a interação entre os recursos. |

---

## ⚙️ Detalhes da Infraestrutura

*A seguir, uma visão detalhada da configuração de cada componente fundamental da arquitetura.*

### 🏛️ **Rede (VPC)**
Foi provisionada uma VPC customizada (`wordpress-final-vpc`) com sub-redes públicas e privadas em duas Zonas de Disponibilidade na região `us-east-1`. Um NAT Gateway foi configurado para permitir que os recursos nas sub-redes privadas acessem a internet para atualizações de software.

<div align="center">
  <img src="imagens/vpc-mapa-recursos.png" alt="Configuração da VPC e Sub-redes" width="700"/>
  <p><em>Mapa de Recursos da VPC, mostrando sub-redes, tabelas de rotas e gateways.</em></p>
</div>

### 🛡️ **Segurança (Security Groups)**
Uma estratégia de "defesa em profundidade" foi aplicada com Security Groups específicos para cada camada, liberando apenas o tráfego essencial.

<div align="center">
  <img src="imagens/sg-lista-final.png" alt="Configuração dos Security Groups" width="700"/>
  <p><em>Grupos de segurança para ALB, EC2, EFS e RDS.</em></p>
</div>

### 👤 **Identidade (IAM)**
Uma IAM Role (`wordpress-ec2-role`) foi criada e associada às instâncias EC2, concedendo as permissões necessárias para interagir com o EFS e o Systems Manager.

<div align="center">
  <img src="imagens/iam-role.png" alt="Configuração da IAM Role" width="700"/>
  <p><em>Role criada para permitir que as instâncias EC2 acessem outros serviços.</em></p>
</div>

---

## 🚀 Arquivos de Configuração e Automação

### 1. `docker-compose.yml`
Este arquivo define o serviço do WordPress, suas variáveis de ambiente e como o armazenamento (volumes) deve ser mapeado.

```yaml
version: '3.7'
services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: "<span class="math-inline">\{DB\_HOST\}"
WORDPRESS\_DB\_NAME\: "</span>{DB_NAME}"
      WORDPRESS_DB_USER: "<span class="math-inline">\{DB\_USER\}"
WORDPRESS\_DB\_PASSWORD\: "</span>{DB_PASSWORD}"
    volumes:
      - /mnt/efs/wp-content:/var/www/html/wp-content
```

### 2. `scripts/user_data.sh` (User Data)
Este script BASH é o cérebro da automação. Inserido no Launch Template, ele configura cada nova instância do zero, incluindo o download do arquivo `docker-compose.yml` do próprio repositório Git.

> **⚠️ Atenção:** Antes de usar, é crucial preencher as variáveis marcadas com os valores correspondentes do seu ambiente AWS (ID do EFS e credenciais do RDS).

```bash
#!/bin/bash
set -euxo pipefail
exec > /var/log/user-data.log 2>&1

# --- PREENCHA SUAS VARIÁVEIS AQUI ---
EFS_ID="seu-id-do-efs"
DB_HOST="seu-endpoint-do-rds"
DB_USER="seu-usuario-rds"
DB_PASSWORD="sua-senha-segura-aqui"
# URL para o arquivo docker-compose.yml cru (raw) no seu GitHub
DOCKER_COMPOSE_URL="[https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/docker-compose.yml](https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/docker-compose.yml)"
# --- FIM DAS VARIÁVEIS ---

# Constantes do Projeto
EFS_MOUNT_DIR="/mnt/efs"
DB_NAME="wordpress_db"

# 1. Instalação de Pacotes
sudo dnf update -y
sudo dnf install -y docker amazon-efs-utils git --allowerasing

# 2. Configuração do Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# 3. Montagem do EFS
sudo mkdir -p ${EFS_MOUNT_DIR}
sudo mount -t efs -o tls ${EFS_ID}:/ <span class="math-inline">\{EFS\_MOUNT\_DIR\}
echo "</span>{EFS_ID}:/ ${EFS_MOUNT_DIR} efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
sudo mkdir -p ${EFS_MOUNT_DIR}/wp-content
sudo chown -R 33:33 ${EFS_MOUNT_DIR}/wp-content
sudo chmod -R 775 <span class="math-inline">\{EFS\_MOUNT\_DIR\}/wp\-content
\# 4\. Preparação e Execução do Docker Compose
cd /home/ec2\-user
\# Cria o arquivo \.env com as credenciais do banco de dados
cat \> \.env <<EOF
DB\_HOST\=</span>{DB_HOST}
DB_NAME=<span class="math-inline">\{DB\_NAME\}
DB\_USER\=</span>{DB_USER}
DB_PASSWORD=${DB_PASSWORD}
EOF

# Baixa o docker-compose.yml do repositório GitHub
curl -o docker-compose.yml ${DOCKER_COMPOSE_URL}

# Inicia o container do WordPress
sudo docker compose up -d
echo "WordPress iniciado com sucesso em: $(date)"
```
---

## ✅ Resultado Final

Após a conclusão de todos os passos, a arquitetura está totalmente operacional. O acesso ao site é feito através do **Nome DNS do Application Load Balancer**. O resultado é a tela de instalação padrão do WordPress, confirmando que todos os componentes estão se comunicando corretamente e que o projeto foi um sucesso.

<div align="center">
  <img src="imagens/wordpress-rodando.png" alt="WordPress Rodando via Load Balancer" width="800"/>
  <p><em>Tela de instalação do WordPress, acessada via DNS do Load Balancer.</em></p>
</div>

