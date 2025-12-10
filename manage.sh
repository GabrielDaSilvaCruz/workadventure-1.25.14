#!/bin/bash

# WorkAdventure Management Script
# Este script facilita o gerenciamento da aplicação

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funções auxiliares
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${NC}ℹ $1${NC}"
}

# Verificar se Docker está instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker não está instalado!"
        echo "Instale o Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose não está instalado!"
        echo "Instale o Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    print_success "Docker e Docker Compose estão instalados"
}

# Iniciar aplicação
start() {
    print_info "Iniciando WorkAdventure..."
    docker compose up -d
    print_success "Aplicação iniciada!"
    echo ""
    print_info "Acesse:"
    echo "  - Frontend: http://play.wocc.com.br"
    echo "  - Map Storage: http://map-storage.wocc.com.br"
    echo "  - Traefik: http://traefik.wocc.com.br"
}

# Parar aplicação
stop() {
    print_info "Parando WorkAdventure..."
    docker compose down
    print_success "Aplicação parada!"
}

# Reiniciar aplicação
restart() {
    print_info "Reiniciando WorkAdventure..."
    docker compose restart
    print_success "Aplicação reiniciada!"
}

# Ver logs
logs() {
    if [ -z "$1" ]; then
        docker compose logs -f
    else
        docker compose logs -f "$1"
    fi
}

# Status dos serviços
status() {
    print_info "Status dos serviços:"
    docker compose ps
}

# Limpar tudo (cuidado!)
clean() {
    print_warning "ATENÇÃO: Isso vai remover TODOS os containers, volumes e imagens!"
    read -p "Tem certeza? (digite 'sim' para confirmar): " confirm
    
    if [ "$confirm" = "sim" ]; then
        print_info "Limpando..."
        docker compose down -v
        docker system prune -af
        print_success "Limpeza concluída!"
    else
        print_info "Operação cancelada"
    fi
}

# Backup dos mapas
backup() {
    BACKUP_DIR="./backups"
    DATE=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p "$BACKUP_DIR"
    
    print_info "Criando backup dos mapas..."
    tar -czf "$BACKUP_DIR/maps_$DATE.tar.gz" maps/
    
    print_success "Backup criado: $BACKUP_DIR/maps_$DATE.tar.gz"
}

# Restaurar backup
restore() {
    if [ -z "$1" ]; then
        print_error "Especifique o arquivo de backup!"
        echo "Uso: $0 restore <arquivo.tar.gz>"
        exit 1
    fi
    
    if [ ! -f "$1" ]; then
        print_error "Arquivo não encontrado: $1"
        exit 1
    fi
    
    print_warning "ATENÇÃO: Isso vai substituir os mapas atuais!"
    read -p "Tem certeza? (digite 'sim' para confirmar): " confirm
    
    if [ "$confirm" = "sim" ]; then
        print_info "Restaurando backup..."
        tar -xzf "$1"
        print_success "Backup restaurado!"
    else
        print_info "Operação cancelada"
    fi
}

# Atualizar código
update() {
    print_info "Atualizando código..."
    
    # Fazer backup antes
    backup
    
    # Atualizar código
    git pull origin main
    
    # Reconstruir e reiniciar
    print_info "Reconstruindo containers..."
    docker compose down
    docker compose up -d --build
    
    print_success "Atualização concluída!"
}

# Verificar saúde dos serviços
health() {
    print_info "Verificando saúde dos serviços..."
    echo ""
    
    # Verificar cada serviço
    services=("play" "back" "map-storage" "maps" "redis")
    
    for service in "${services[@]}"; do
        if docker compose ps "$service" | grep -q "Up"; then
            print_success "$service está rodando"
        else
            print_error "$service está parado ou com problemas"
        fi
    done
}

# Mostrar uso
usage() {
    echo "WorkAdventure Management Script"
    echo ""
    echo "Uso: $0 <comando> [opções]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  start           - Iniciar a aplicação"
    echo "  stop            - Parar a aplicação"
    echo "  restart         - Reiniciar a aplicação"
    echo "  logs [serviço]  - Ver logs (todos ou de um serviço específico)"
    echo "  status          - Ver status dos serviços"
    echo "  health          - Verificar saúde dos serviços"
    echo "  backup          - Fazer backup dos mapas"
    echo "  restore <file>  - Restaurar backup dos mapas"
    echo "  update          - Atualizar código e reconstruir"
    echo "  clean           - Limpar tudo (containers, volumes, imagens)"
    echo "  help            - Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 start"
    echo "  $0 logs map-storage"
    echo "  $0 backup"
    echo "  $0 restore backups/maps_20231209_120000.tar.gz"
}

# Main
case "$1" in
    start)
        check_docker
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    logs)
        logs "$2"
        ;;
    status)
        status
        ;;
    health)
        health
        ;;
    backup)
        backup
        ;;
    restore)
        restore "$2"
        ;;
    update)
        update
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        print_error "Comando desconhecido: $1"
        echo ""
        usage
        exit 1
        ;;
esac
