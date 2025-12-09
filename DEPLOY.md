# Guia de Deploy - WorkAdventure

Este guia detalha como fazer o deploy do WorkAdventure em um servidor de produção.

## 📋 Pré-requisitos

### Servidor
- Ubuntu 20.04+ ou Debian 11+
- Mínimo 4GB RAM (8GB recomendado)
- 20GB de espaço em disco
- Acesso root ou sudo

### Domínio e DNS
- Um domínio próprio (ex: `seudominio.com`)
- Acesso ao painel de DNS
- Configurar os seguintes registros A:
  ```
  play.seudominio.com     -> IP_DO_SERVIDOR
  map-storage.seudominio.com -> IP_DO_SERVIDOR
  maps.seudominio.com     -> IP_DO_SERVIDOR
  ```

## 🔧 Instalação no Servidor

### 1. Instalar Docker e Docker Compose

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Adicionar repositório Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
newgrp docker

# Verificar instalação
docker --version
docker compose version
```

### 2. Clonar o Repositório

```bash
# Criar diretório para a aplicação
sudo mkdir -p /opt/workadventure
sudo chown $USER:$USER /opt/workadventure
cd /opt/workadventure

# Clonar repositório
git clone <SEU_REPOSITORIO_GITHUB> .
```

### 3. Configurar Variáveis de Ambiente

```bash
# Copiar template
cp .env.template .env

# Editar configurações
nano .env
```

Configurações essenciais para produção:

```env
# Domínios
DOMAIN=seudominio.com
PUSHER_URL=https://play.seudominio.com
FRONT_URL=https://play.seudominio.com
PUBLIC_MAP_STORAGE_URL=https://map-storage.seudominio.com
INTERNAL_MAP_STORAGE_URL=http://map-storage:3000

# Segurança (GERE VALORES ÚNICOS!)
SECRET_KEY=$(openssl rand -hex 32)
MAP_STORAGE_API_TOKEN=$(openssl rand -hex 32)

# Map Editor
ENABLE_MAP_EDITOR=true

# Chat (opcional)
ENABLE_CHAT=true
ENABLE_CHAT_UPLOAD=false

# Debug (desabilitar em produção)
DEBUG_MODE=false
```

### 4. Configurar SSL com Let's Encrypt

Crie um arquivo `docker-compose.prod.yaml`:

```yaml
version: "3.6"
services:
  reverse-proxy:
    image: traefik:v2.11
    command:
      - --api.insecure=false
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.letsencrypt.acme.email=seu-email@exemplo.com
      - --certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json
      - --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web
      # Redirect HTTP to HTTPS
      - --entrypoints.web.http.redirections.entrypoint.to=websecure
      - --entrypoints.web.http.redirections.entrypoint.scheme=https
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./letsencrypt:/letsencrypt
    restart: unless-stopped

  play:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.play.rule=Host(`play.${DOMAIN}`)"
      - "traefik.http.routers.play.entrypoints=websecure"
      - "traefik.http.routers.play.tls.certresolver=letsencrypt"
      - "traefik.http.services.play.loadbalancer.server.port=3000"
    restart: unless-stopped

  map-storage:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.map-storage.rule=Host(`map-storage.${DOMAIN}`)"
      - "traefik.http.routers.map-storage.entrypoints=websecure"
      - "traefik.http.routers.map-storage.tls.certresolver=letsencrypt"
      - "traefik.http.services.map-storage.loadbalancer.server.port=3000"
    restart: unless-stopped

  maps:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.maps.rule=Host(`maps.${DOMAIN}`)"
      - "traefik.http.routers.maps.entrypoints=websecure"
      - "traefik.http.routers.maps.tls.certresolver=letsencrypt"
      - "traefik.http.services.maps.loadbalancer.server.port=80"
    restart: unless-stopped

  back:
    restart: unless-stopped

  redis:
    restart: unless-stopped
```

### 5. Iniciar Aplicação

```bash
# Criar diretório para certificados SSL
mkdir -p letsencrypt
chmod 600 letsencrypt

# Iniciar serviços
docker compose -f docker-compose.yaml -f docker-compose.prod.yaml up -d

# Verificar status
docker compose ps

# Ver logs
docker compose logs -f
```

## 🔒 Segurança

### Firewall

```bash
# Instalar UFW
sudo apt install -y ufw

# Configurar regras
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Ativar firewall
sudo ufw enable
sudo ufw status
```

### Backup Automático

Crie um script de backup:

```bash
#!/bin/bash
# /opt/workadventure/backup.sh

BACKUP_DIR="/opt/backups/workadventure"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup dos mapas
tar -czf $BACKUP_DIR/maps_$DATE.tar.gz /opt/workadventure/maps/

# Backup do banco de dados Redis (se usado)
docker exec workadventure-redis redis-cli SAVE
docker cp workadventure-redis:/data/dump.rdb $BACKUP_DIR/redis_$DATE.rdb

# Manter apenas últimos 7 dias
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.rdb" -mtime +7 -delete

echo "Backup concluído: $DATE"
```

Agendar com cron:

```bash
chmod +x /opt/workadventure/backup.sh
crontab -e

# Adicionar linha (backup diário às 2h da manhã)
0 2 * * * /opt/workadventure/backup.sh >> /var/log/workadventure-backup.log 2>&1
```

## 📊 Monitoramento

### Logs

```bash
# Ver logs em tempo real
docker compose logs -f

# Logs de um serviço específico
docker compose logs -f map-storage

# Últimas 100 linhas
docker compose logs --tail=100
```

### Recursos do Sistema

```bash
# Uso de recursos por container
docker stats

# Espaço em disco
df -h
docker system df
```

### Health Checks

Adicione ao `docker-compose.prod.yaml`:

```yaml
services:
  map-storage:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## 🔄 Atualizações

### Atualizar Código

```bash
cd /opt/workadventure

# Fazer backup antes
./backup.sh

# Atualizar código
git pull origin main

# Reconstruir e reiniciar
docker compose down
docker compose -f docker-compose.yaml -f docker-compose.prod.yaml up -d --build
```

### Rollback

```bash
# Voltar para commit anterior
git log --oneline  # Ver commits
git checkout <commit-hash>

# Reconstruir
docker compose down
docker compose -f docker-compose.yaml -f docker-compose.prod.yaml up -d --build
```

## 🐛 Troubleshooting em Produção

### Serviço não inicia

```bash
# Ver logs detalhados
docker compose logs <servico>

# Verificar configuração
docker compose config

# Reiniciar serviço específico
docker compose restart <servico>
```

### Certificado SSL não funciona

```bash
# Verificar logs do Traefik
docker compose logs reverse-proxy

# Verificar permissões
ls -la letsencrypt/

# Forçar renovação
docker compose exec reverse-proxy rm /letsencrypt/acme.json
docker compose restart reverse-proxy
```

### Alto uso de memória

```bash
# Ver uso por container
docker stats

# Limitar recursos no docker-compose.prod.yaml
services:
  play:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

## 📈 Otimizações

### Performance

1. **Habilitar compressão Gzip** no Traefik
2. **Configurar cache** para assets estáticos
3. **Usar CDN** para mapas e tilesets grandes
4. **Otimizar imagens** dos mapas (PNG -> WebP)

### Escalabilidade

Para ambientes com muitos usuários:

```yaml
services:
  play:
    deploy:
      replicas: 3
      
  back:
    deploy:
      replicas: 2
```

## 🆘 Suporte

- **Logs**: Sempre verifique os logs primeiro
- **GitHub Issues**: Reporte problemas específicos
- **Documentação**: Consulte o README.md principal

## ✅ Checklist de Deploy

- [ ] Servidor configurado com Docker
- [ ] DNS configurado corretamente
- [ ] Variáveis de ambiente configuradas
- [ ] SSL/TLS configurado
- [ ] Firewall configurado
- [ ] Backup automático configurado
- [ ] Monitoramento ativo
- [ ] Teste de criação/edição de mapas
- [ ] Teste de persistência de objetos
- [ ] Documentação atualizada
