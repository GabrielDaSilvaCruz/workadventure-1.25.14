# 🚀 Guia Rápido - Preparação para GitHub

## ✅ Arquivos Criados

Os seguintes arquivos foram criados para facilitar o deploy e manutenção:

1. **README.md** - Documentação principal do projeto
2. **DEPLOY.md** - Guia completo de deploy para produção
3. **CHANGELOG.md** - Histórico de mudanças
4. **.gitignore** - Arquivos a serem ignorados pelo Git
5. **manage.sh** - Script de gerenciamento (executável)

## 📝 Antes de Subir para o GitHub

### 1. Inicializar Git (se ainda não foi feito)

```bash
cd /home/gabriel-da-silva-cruz/Documentos/workadventure-1.25.14

# Inicializar repositório
git init

# Adicionar todos os arquivos
git add .

# Primeiro commit
git commit -m "Initial commit: WorkAdventure 1.25.14 with map editor fixes"
```

### 2. Criar Repositório no GitHub

1. Acesse https://github.com/new
2. Nome sugerido: `workadventure-custom` ou `workadventure-map-editor`
3. Descrição: "WorkAdventure with map editor fixes and object persistence"
4. Escolha: **Public** ou **Private**
5. **NÃO** inicialize com README (já temos um)
6. Clique em "Create repository"

### 3. Conectar ao GitHub

```bash
# Adicionar remote (substitua SEU_USUARIO e SEU_REPO)
git remote add origin https://github.com/SEU_USUARIO/SEU_REPO.git

# Renomear branch para main (se necessário)
git branch -M main

# Push inicial
git push -u origin main
```

## 🔒 Segurança - IMPORTANTE!

### Arquivos Sensíveis

Verifique se estes arquivos **NÃO** estão no Git:

```bash
# Verificar o que será commitado
git status

# Se algum destes aparecer, adicione ao .gitignore:
# - .env (variáveis de ambiente)
# - node_modules/ (dependências)
# - *.log (logs)
# - letsencrypt/ (certificados SSL)
```

### Limpar Histórico de Senhas (se necessário)

Se você acidentalmente commitou senhas:

```bash
# Remover arquivo do histórico
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (CUIDADO!)
git push origin --force --all
```

## 📦 Estrutura Recomendada de Branches

```bash
# Branch principal (produção)
main

# Branch de desenvolvimento
git checkout -b develop

# Branches de features
git checkout -b feature/nova-funcionalidade

# Branches de fixes
git checkout -b fix/correcao-bug
```

## 🎯 Próximos Passos

### Para Desenvolvimento Local

```bash
# Usar o script de gerenciamento
./manage.sh start      # Iniciar
./manage.sh logs       # Ver logs
./manage.sh status     # Ver status
./manage.sh backup     # Fazer backup
```

### Para Deploy em Servidor

1. Siga o guia em **DEPLOY.md**
2. Configure DNS apontando para seu servidor
3. Configure SSL com Let's Encrypt
4. Execute `./manage.sh start` no servidor

## 📋 Checklist Pré-Deploy

- [ ] Código commitado no Git
- [ ] Repositório criado no GitHub
- [ ] Push realizado com sucesso
- [ ] README.md revisado
- [ ] .gitignore configurado
- [ ] Variáveis de ambiente documentadas
- [ ] Backup dos mapas atuais feito
- [ ] Testado localmente
- [ ] DEPLOY.md revisado

## 🔄 Workflow Sugerido

### Desenvolvimento

```bash
# 1. Criar branch de feature
git checkout -b feature/minha-feature

# 2. Fazer mudanças
# ... editar arquivos ...

# 3. Commit
git add .
git commit -m "feat: adiciona minha feature"

# 4. Push
git push origin feature/minha-feature

# 5. Criar Pull Request no GitHub
```

### Produção

```bash
# 1. Merge da feature na main
git checkout main
git merge feature/minha-feature

# 2. Tag de versão
git tag -a v1.25.14-custom.1 -m "Release v1.25.14-custom.1"
git push origin v1.25.14-custom.1

# 3. Deploy no servidor
ssh usuario@servidor
cd /opt/workadventure
git pull origin main
./manage.sh update
```

## 📚 Documentação Adicional

### Arquivos Importantes

- `README.md` - Leia primeiro!
- `DEPLOY.md` - Para deploy em produção
- `CHANGELOG.md` - Histórico de mudanças
- `docker-compose.yaml` - Configuração dos serviços

### Comandos Úteis

```bash
# Ver documentação do script de gerenciamento
./manage.sh help

# Ver status dos containers
docker compose ps

# Ver logs em tempo real
docker compose logs -f

# Reiniciar um serviço específico
docker compose restart map-storage

# Verificar saúde dos serviços
./manage.sh health
```

## 🆘 Problemas Comuns

### Git não reconhece mudanças

```bash
git status
git add .
git commit -m "Descrição das mudanças"
```

### Erro ao fazer push

```bash
# Se o remote não existe
git remote -v
git remote add origin https://github.com/SEU_USUARIO/SEU_REPO.git

# Se há conflitos
git pull origin main --rebase
git push origin main
```

### Arquivo muito grande

```bash
# Ver tamanho dos arquivos
du -sh *

# Adicionar ao .gitignore se necessário
echo "arquivo-grande.zip" >> .gitignore
git rm --cached arquivo-grande.zip
```

## 🎉 Pronto!

Seu projeto está preparado para:
- ✅ Ser versionado no Git
- ✅ Ser compartilhado no GitHub
- ✅ Ser deployado em produção
- ✅ Ser mantido e atualizado facilmente

## 📞 Suporte

- **Issues**: Use o GitHub Issues para reportar problemas
- **Documentação**: Consulte README.md e DEPLOY.md
- **Logs**: Sempre verifique os logs primeiro (`./manage.sh logs`)

---

**Última atualização**: 2025-12-09
**Versão**: 1.25.14-custom
