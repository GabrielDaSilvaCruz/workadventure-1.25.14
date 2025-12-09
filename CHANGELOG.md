# Changelog - WorkAdventure Custom

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

## [1.25.14-custom] - 2025-12-09

### 🔧 Correções (Fixes)

#### Map Editor - Persistência de Objetos
- **Problema**: Objetos (entidades) adicionados ao mapa não eram salvos
- **Causa Raiz**: O parâmetro `userCanEdit` estava sendo enviado como `false` do frontend para o backend, bloqueando a criação de entidades através da verificação de permissões no `EntityPermissions.canEdit()`
- **Solução Temporária**: Forçado `canEdit = true` no backend (`back/src/Model/GameRoom.ts:255`)
- **Arquivos Modificados**:
  - `back/src/Model/GameRoom.ts`
- **Nota**: Esta é uma solução temporária. Para produção, deve-se investigar por que `joinRoomMessage.canEdit` vem como `false` e implementar um sistema de permissões adequado.

### 🧹 Limpeza de Código

#### Remoção de Logs de Debug
Removidos logs de debug adicionados durante investigação:
- `map-storage/src/MapStorageServer.ts`
- `map-storage/src/MapsManager.ts`
- `map-storage/src/Upload/DiskFileSystem.ts`

### 📚 Documentação

#### Adicionado
- `README.md` - Documentação completa do projeto
- `DEPLOY.md` - Guia detalhado de deploy para produção
- `CHANGELOG.md` - Este arquivo
- `.gitignore` - Configuração para Git

#### Conteúdo do README.md
- Instruções de instalação local
- Configuração para produção
- Troubleshooting
- Estrutura de mapas
- Notas sobre permissões e autenticação

#### Conteúdo do DEPLOY.md
- Pré-requisitos de servidor
- Instalação passo-a-passo
- Configuração SSL com Let's Encrypt
- Segurança e firewall
- Backup automático
- Monitoramento
- Otimizações de performance

### 🔍 Investigação Realizada

Durante a resolução do problema de persistência, foram investigados:

1. **Fluxo de Salvamento**:
   - `MapStorageServer.handleEditMapCommandWithKeyMessage()` - Recebe comandos de edição
   - `MapsManager.executeCommand()` - Executa comandos no GameMap
   - `MapsManager.startSavingMapInterval()` - Inicia salvamento automático
   - `DiskFileSystem.writeStringAsFile()` - Escreve arquivo .wam no disco

2. **Sistema de Permissões**:
   - `EntityPermissions.canEdit()` - Verifica se usuário pode editar
   - Verificação de áreas com permissão de escrita
   - Tags de usuário e UUID

3. **Fluxo de Dados**:
   ```
   Frontend (RoomConnection.ts)
     ↓ canEdit = true (local)
   Pusher
     ↓ joinRoomMessage.canEdit = false
   Backend (GameRoom.ts)
     ↓ user.canEdit = false
   Map Storage
     ↓ userCanEdit = false
   EntityPermissions
     ↓ BLOQUEIO ❌
   ```

### ⚠️ Problemas Conhecidos

1. **Permissões de Edição**:
   - Fix temporário força `canEdit = true` para todos
   - Não há controle de permissões real
   - Todos os usuários podem editar todos os mapas

2. **Autenticação**:
   - OpenID Connect não configurado por padrão
   - Sem sistema de usuários/roles

### 🎯 TODO / Próximos Passos

- [ ] Investigar origem do `joinRoomMessage.canEdit = false`
- [ ] Implementar sistema de permissões adequado
- [ ] Configurar autenticação OpenID Connect
- [ ] Adicionar testes automatizados
- [ ] Implementar CI/CD
- [ ] Documentar API do Map Storage
- [ ] Criar guia de criação de mapas
- [ ] Adicionar exemplos de mapas

### 📦 Dependências

Baseado em:
- WorkAdventure v1.25.14
- Node.js 20+
- Docker & Docker Compose
- Traefik v2.11

### 🔗 Links Úteis

- [WorkAdventure Original](https://github.com/workadventure/workadventure)
- [Documentação Oficial](https://workadventu.re/docs/)
- [Map Building Guide](https://workadventu.re/map-building/)

---

## Formato

Este changelog segue o formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

### Tipos de Mudanças

- `Added` (Adicionado) para novos recursos
- `Changed` (Modificado) para mudanças em recursos existentes
- `Deprecated` (Obsoleto) para recursos que serão removidos
- `Removed` (Removido) para recursos removidos
- `Fixed` (Corrigido) para correções de bugs
- `Security` (Segurança) para vulnerabilidades corrigidas
