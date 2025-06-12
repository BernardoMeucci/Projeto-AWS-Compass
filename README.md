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
  <img src="imagens/arquitetura-final.png.webp" alt="Diagrama da Arquitetura Final na AWS" width="800"/>
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
  <img src="imagens/vpc-mapa-recursos.png.jpg" alt="Configuração da VPC e Sub-redes" width="700"/>
  <p><em>Mapa de Recursos da VPC, mostrando sub-redes, tabelas de rotas e gateways.</em></p>
</div>

### 🛡️ **Segurança (Security Groups)**
Uma estratégia de "defesa em profundidade" foi aplicada com Security Groups específicos para cada camada, liberando apenas o tráfego essencial.

<div align="center">
  <img src="imagens/sg-lista-final.png.jpg" alt="Configuração dos Security Groups" width="700"/>
  <p><em>Grupos de segurança para ALB, EC2, EFS e RDS.</em></p>
</div>

### 👤 **Identidade (IAM)**
Uma IAM Role (`wordpress-ec2-role`) foi criada e associada às instâncias EC2, concedendo as permissões necessárias para interagir com o EFS e o Systems Manager.

<div align="center">
  <img src="imagens/iam-role.png.jpg" alt="Configuração da IAM Role" width="700"/>
  <p><em>Role criada para permitir que as instâncias EC2 acessem outros serviços.</em></p>
</div>

---


---

## ✅ Resultado Final

Após a conclusão de todos os passos, a arquitetura está totalmente operacional. O acesso ao site é feito através do **Nome DNS do Application Load Balancer**. O resultado é a tela de instalação padrão do WordPress, confirmando que todos os componentes estão se comunicando corretamente e que o projeto foi um sucesso.

<div align="center">
  <img src="imagens/wordpress-rodando.png.jpg" alt="WordPress Rodando via Load Balancer" width="800"/>
  <p><em>Tela de instalação do WordPress, acessada via DNS do Load Balancer.</em></p>
</div>

