#!/bin/bash
# Configuração de hosts para o SERVIDOR (localhost)

sudo tee -a /etc/hosts > /dev/null << 'HOSTS_EOF'

# WorkAdventure - Localhost
127.0.0.1 oidc.wocc.com.br redis.wocc.com.br play.wocc.com.br traefik.wocc.com.br matrix.wocc.com.br extra.wocc.com.br icon.wocc.com.br map-storage.wocc.com.br uploader.wocc.com.br maps.wocc.com.br api.wocc.com.br front.wocc.com.brHOSTS_EOF

echo "✅ Hosts configurados no servidor!"
