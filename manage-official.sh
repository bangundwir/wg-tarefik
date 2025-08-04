#!/bin/bash

TRAEFIK_DIR="/etc/docker/containers/traefik"
WGEASY_DIR="/etc/docker/containers/wg-easy"

show_help() {
    echo "=== WG-Easy Official Directory Management ==="
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Setup Commands:"
    echo "  setup-official    Setup using official directory structure"
    echo ""
    echo "Service Commands:"
    echo "  start-all         Start both Traefik and WG-Easy"
    echo "  stop-all          Stop both services"
    echo "  restart-all       Restart both services"
    echo "  status-all        Show status of both services"
    echo ""
    echo "Individual Commands:"
    echo "  traefik-start     Start Traefik"
    echo "  traefik-stop      Stop Traefik"
    echo "  traefik-logs      View Traefik logs"
    echo "  traefik-restart   Restart Traefik"
    echo ""
    echo "  wg-start          Start WG-Easy"
    echo "  wg-stop           Stop WG-Easy"
    echo "  wg-logs           View WG-Easy logs"
    echo "  wg-restart        Restart WG-Easy"
    echo ""
    echo "Utility Commands:"
    echo "  update-all        Update both services"
    echo "  cleanup-official  Clean up official installation"
    echo "  help              Show this help"
}

setup_official() {
    echo "Setting up official directory structure..."
    ./setup-official.sh
}

start_all() {
    echo "Starting all services (official structure)..."
    cd $TRAEFIK_DIR && sudo docker compose up -d
    cd $WGEASY_DIR && sudo docker compose up -d
    echo "Services started!"
}

stop_all() {
    echo "Stopping all services..."
    cd $WGEASY_DIR && sudo docker compose down
    cd $TRAEFIK_DIR && sudo docker compose down
    echo "Services stopped!"
}

restart_all() {
    echo "Restarting all services..."
    cd $TRAEFIK_DIR && sudo docker compose restart
    cd $WGEASY_DIR && sudo docker compose restart
    echo "Services restarted!"
}

status_all() {
    echo "=== Service Status ==="
    echo "Traefik:"
    cd $TRAEFIK_DIR && sudo docker compose ps
    echo ""
    echo "WG-Easy:"
    cd $WGEASY_DIR && sudo docker compose ps
}

traefik_start() {
    cd $TRAEFIK_DIR && sudo docker compose up -d
    echo "Traefik started!"
}

traefik_stop() {
    cd $TRAEFIK_DIR && sudo docker compose down
    echo "Traefik stopped!"
}

traefik_logs() {
    cd $TRAEFIK_DIR && sudo docker compose logs -f
}

traefik_restart() {
    cd $TRAEFIK_DIR && sudo docker compose restart
    echo "Traefik restarted!"
}

wg_start() {
    cd $WGEASY_DIR && sudo docker compose up -d
    echo "WG-Easy started!"
}

wg_stop() {
    cd $WGEASY_DIR && sudo docker compose down
    echo "WG-Easy stopped!"
}

wg_logs() {
    cd $WGEASY_DIR && sudo docker compose logs -f
}

wg_restart() {
    cd $WGEASY_DIR && sudo docker compose restart
    echo "WG-Easy restarted!"
}

update_all() {
    echo "Updating all services..."
    cd $TRAEFIK_DIR && sudo docker compose pull && sudo docker compose up -d
    cd $WGEASY_DIR && sudo docker compose pull && sudo docker compose up -d
    echo "Services updated!"
}

cleanup_official() {
    echo "Cleaning up official installation..."
    cd $WGEASY_DIR && sudo docker compose down -v 2>/dev/null || true
    cd $TRAEFIK_DIR && sudo docker compose down -v 2>/dev/null || true
    
    sudo rm -rf /etc/docker/containers/traefik
    sudo rm -rf /etc/docker/containers/wg-easy
    sudo rm -rf /etc/docker/volumes/traefik
    
    sudo docker network rm traefik 2>/dev/null || true
    echo "Official installation cleaned up!"
}

# Check if official directories exist
check_official() {
    if [ ! -d "$TRAEFIK_DIR" ] || [ ! -d "$WGEASY_DIR" ]; then
        echo "❌ Official directory structure not found!"
        echo "Run: $0 setup-official"
        exit 1
    fi
}

# Main script logic
case "$1" in
    setup-official) setup_official ;;
    start-all) check_official && start_all ;;
    stop-all) check_official && stop_all ;;
    restart-all) check_official && restart_all ;;
    status-all) check_official && status_all ;;
    traefik-start) check_official && traefik_start ;;
    traefik-stop) check_official && traefik_stop ;;
    traefik-logs) check_official && traefik_logs ;;
    traefik-restart) check_official && traefik_restart ;;
    wg-start) check_official && wg_start ;;
    wg-stop) check_official && wg_stop ;;
    wg-logs) check_official && wg_logs ;;
    wg-restart) check_official && wg_restart ;;
    update-all) check_official && update_all ;;
    cleanup-official) cleanup_official ;;
    help|--help|-h) show_help ;;
    "") echo "No command specified. Use '$0 help' for usage information." ;;
    *) echo "Unknown command: $1"; show_help; exit 1 ;;
esac
