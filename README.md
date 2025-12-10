# WorkAdventure - Versão Customizada

Esta é uma versão customizada do WorkAdventure 1.25.14 com correções específicas para permitir a edição de mapas e persistência de objetos.

## 🔧 Correções Aplicadas

### 1. Fix: Persistência de Objetos no Mapa
**Arquivo**: `back/src/Model/GameRoom.ts` (linha 255)
- **Problema**: Objetos (cadeiras, mesas, etc.) não eram salvos no mapa
- **Causa**: O parâmetro `userCanEdit` estava sendo enviado como `false`, bloqueando a criação de entidades
- **Solução**: Forçado `canEdit = true` temporariamente no backend

```typescript
// Linha 255 em back/src/Model/GameRoom.ts
true, // joinRoomMessage.canEdit, // TEMPORARY FIX: Force canEdit to true
```

## 🚀 Como Executar Localmente

### Pré-requisitos
- Docker e Docker Compose instalados
- Node.js 20+ (para desenvolvimento)
- Portas 80, 8080, 3000, 3001 disponíveis

### Passos

1. **Clone o repositório**
```bash
git clone <seu-repositorio>
cd workadventure-1.25.14
```

2. **Inicie os serviços com Docker Compose**
```bash
docker-compose up -d
```

3. **Aguarde os serviços iniciarem** (pode levar alguns minutos na primeira vez)

4. **Acesse a aplicação**
- Frontend: http://play.wocc.com.br
- Map Storage: http://map-storage.wocc.com.br
- Traefik Dashboard: http://traefik.wocc.com.br

### Verificar Status dos Serviços

```bash
# Ver logs de todos os serviços
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f map-storage
docker-compose logs -f play
docker-compose logs -f back
```

## 📝 Configuração para Produção

### 1. Variáveis de Ambiente

Crie um arquivo `.env` baseado no `.env.template`:

```bash
cp .env.template .env
```

Edite o `.env` com suas configurações:

```env
# Domínio principal
DOMAIN=seu-dominio.com

# URLs públicas
PUSHER_URL=https://play.seu-dominio.com
FRONT_URL=https://play.seu-dominio.com
PUBLIC_MAP_STORAGE_URL=https://map-storage.seu-dominio.com

# Map Storage
INTERNAL_MAP_STORAGE_URL=http://map-storage:3000
MAP_STORAGE_API_TOKEN=<gere-um-token-seguro>

# Segurança
SECRET_KEY=<gere-uma-chave-secreta>

# OpenID (opcional)
ENABLE_OPENID=false
```

### 2. Docker Compose para Produção

Use o arquivo `docker-compose.prod.yaml` (você precisará criar):

```yaml
version: "3.6"
services:
  # Adicione configurações de produção aqui
  # - Volumes persistentes
  # - Limites de recursos
  # - Health checks
  # - Restart policies
```

### 3. Reverse Proxy (Nginx/Traefik)

Configure SSL/TLS com Let's Encrypt para produção.

## 🗺️ Estrutura de Mapas

Os mapas ficam em `/maps`:

```
maps/
├── starter/
│   ├── map.json          # Mapa base Tiled
│   ├── map.wam           # Arquivo de entidades WorkAdventure
│   └── tileset.png       # Tilesets
└── collections/
    ├── FurnitureCollection.json
    └── OfficeCollection.json
```

### Criar um Novo Mapa

1. Crie uma pasta em `/maps/seu-mapa/`
2. Adicione o arquivo `.tmj` (Tiled JSON)
3. O arquivo `.wam` será criado automaticamente ao editar
4. Acesse: `http://play.wocc.com.br/_/global/maps.wocc.com.br/seu-mapa/map.tmj`

## 🔐 Permissões e Autenticação

### Configuração Atual
- **Map Editor**: Habilitado por padrão (`ENABLE_MAP_EDITOR=true`)
- **Edição de Mapas**: Todos os usuários podem editar (fix temporário)
- **Autenticação**: Desabilitada por padrão

### Para Produção (Recomendado)
Configure OpenID Connect editando o `docker-compose.yaml`:

```yaml
environment:
  ENABLE_OPENID: "true"
  OPID_CLIENT_ID: seu-client-id
  OPID_CLIENT_SECRET: seu-client-secret
  OPID_CLIENT_ISSUER: https://seu-provider.com
```

## 🐛 Troubleshooting

### Objetos não aparecem no mapa
1. Verifique se o `map-storage` está rodando: `docker-compose ps map-storage`
2. Verifique os logs: `docker-compose logs map-storage`
3. Confirme que o arquivo `.wam` existe em `/maps/seu-mapa/map.wam`

### Erro "WAM file url is undefined"
- Certifique-se de acessar o mapa com a URL correta
- O mapa deve ter um arquivo `.tmj` correspondente

### Serviços não iniciam
```bash
# Limpe containers e volumes
docker-compose down -v

# Reconstrua as imagens
docker-compose build --no-cache

# Inicie novamente
docker-compose up -d
```

## 📚 Documentação Adicional

- [WorkAdventure Docs](https://workadventu.re/docs/)
- [Map Editor Guide](https://workadventu.re/map-building/)
- [Scripting API](https://workadventu.re/map-building/scripting/)

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## ⚠️ Notas Importantes

### Fix Temporário de Permissões
O fix atual em `GameRoom.ts` força `canEdit = true` para todos os usuários. Para produção, você deve:

1. Investigar por que `joinRoomMessage.canEdit` vem como `false`
2. Implementar um sistema de permissões adequado
3. Configurar autenticação/autorização apropriada

### Backup de Mapas
Os mapas são salvos em `/maps`. Certifique-se de fazer backup regular:

```bash
# Backup
tar -czf maps-backup-$(date +%Y%m%d).tar.gz maps/

# Restore
tar -xzf maps-backup-YYYYMMDD.tar.gz
```

## 📄 Licença

Este projeto é baseado no WorkAdventure, que é licenciado sob a licença Apache 2.0.
Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🆘 Suporte

Para problemas específicos desta versão customizada, abra uma issue no GitHub.
Para questões gerais do WorkAdventure, consulte a [documentação oficial](https://workadventu.re/docs/).
