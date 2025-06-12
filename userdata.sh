#!/bin/bash
set -euxo pipefail
exec > /var/log/user-data.log 2>&1

# --- PREENCHA SUAS VARIÁVEIS AQUI ---
#
# 1. Pegue o ID do seu EFS no console da AWS.
EFS_ID="SEU_ID_DO_EFS"

# 2. Pegue o Endpoint e as credenciais do seu RDS no console da AWS.
DB_HOST="SEU_ENDPOINT_DO_RDS"
DB_USER="seu_usuario_rds"
DB_PASSWORD="sua_senha_rds"

# 3. Vá para o seu arquivo docker-compose.yml no GitHub, clique no botão "Raw"
#    e copie o URL da página que abrir.
DOCKER_COMPOSE_URL="URL_RAW_DO_SEU_DOCKER_COMPOSE_NO_GITHUB"
# Exemplo: https://raw.githubusercontent.com/seu-usuario/seu-repo/main/docker-compose.yml
#
# --- FIM DAS VARIÁVEIS ---


# Constantes do Projeto
REGIAO="us-east-1"
EFS_MOUNT_DIR="/mnt/efs"
PROJECT_DIR="/home/ec2-user/wordpress-project"
DB_NAME="wordpress_db"

# Instalação de Pacotes
sudo dnf update -y
sudo dnf install -y docker amazon-efs-utils git --allowerasing

# Configuração do Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Montagem do EFS
sudo mkdir -p ${EFS_MOUNT_DIR}
sudo mount -t efs -o tls ${EFS_ID}:/ ${EFS_MOUNT_DIR}
echo "${EFS_ID}:/ ${EFS_MOUNT_DIR} efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
sudo chown -R 33:33 ${EFS_MOUNT_DIR}

# Preparação do Projeto
sudo mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}

# Cria o arquivo .env com as credenciais do banco de dados de forma segura na instância
cat > .env <<EOF
WORDPRESS_DB_HOST=${DB_HOST}
WORDPRESS_DB_NAME=${DB_NAME}
WORDPRESS_DB_USER=${DB_USER}
WORDPRESS_DB_PASSWORD=${DB_PASSWORD}
EOF

# Baixa o docker-compose.yml do repositório GitHub
curl -o docker-compose.yml ${DOCKER_COMPOSE_URL}

# Ajusta as permissões dos arquivos
sudo chown ec2-user:ec2-user .env docker-compose.yml

# Inicia o container do WordPress usando o Docker Compose V2
sudo docker compose up -d
echo "WordPress iniciado com sucesso em: $(date)" | sudo tee /var/log/wordpress-init.log