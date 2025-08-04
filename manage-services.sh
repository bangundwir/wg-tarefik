#!/bin/bash

show_help() {
    echo "=== WireGuard Easy + Traefik Management ==="
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Installation Commands:"
    echo "  install-traefik    Install Traefik first"
    echo "  install-wg         Install WG-Easy (requires Traefik running)"
    echo "  install-all        Install both Traefik and WG-Easy"
    echo ""
    echo "Management Commands:"
    echo "  start             Start all services"
    echo "  stop              Stop all services"
    echo "  restart           Restart all services"
    echo "  status            Show services status"
    echo "  logs              Show services logs"
    echo ""
    echo "Traefik Commands:"
    echo "  traefik-start     Start only Traefik"
    echo "  traefik-stop      Stop only Traefik"
    echo "  traefik-restart   Restart only Traefik"
    echo "  traefik-logs      Show only Traefik logs"
    echo ""
    echo "WG-Easy Commands:"
    echo "  wg-start          Start only WG-Easy"
    echo "  wg-stop           Stop only WG-Easy"
    echo "  wg-restart        Restart only WG-Easy"
    echo "  wg-logs           Show only WG-Easy logs"
    echo ""
    echo "Utility Commands:"
    echo "  update-dns        Update Duck DNS IP"
    echo "  debug             Run debug script"
    echo "  fix-v15           Fix WG-Easy v15 migration issues"
    echo "  cleanup           Clean up all containers and networks"
    echo "  help              Show this help message"
}

install_traefik() {
    echo "Installing Traefik..."
    ./install-traefik.sh
}

install_wg() {
    echo "Installing WG-Easy..."
    ./install-wg-easy.sh
}

install_all() {
    echo "Installing Traefik first..."
    ./install-traefik.sh
    echo ""
    echo "Waiting 30 seconds for Traefik to stabilize..."
    sleep 30
    echo ""
    echo "Installing WG-Easy..."
    ./install-wg-easy.sh
}

start_all() {
    echo "Starting all services..."
    docker-compose -f traefik-compose.yml up -d
    docker-compose -f wg-easy-compose.yml up -d
    echo "Services started!"
    show_status
}

stop_all() {
    echo "Stopping all services..."
    docker-compose -f wg-easy-compose.yml down
    docker-compose -f traefik-compose.yml down
    echo "Services stopped!"
}

restart_all() {
    echo "Restarting all services..."
    docker-compose -f wg-easy-compose.yml restart
    docker-compose -f traefik-compose.yml restart
    echo "Services restarted!"
    show_status
}

show_status() {
    echo ""
    echo "=== Service Status ==="
    echo "Traefik:"
    docker-compose -f traefik-compose.yml ps
    echo ""
    echo "WG-Easy:"
    docker-compose -f wg-easy-compose.yml ps
    echo ""
    echo "Access URLs:"
    echo "- WireGuard Easy: https://wg.buq.duckdns.org"
    echo "- Traefik Dashboard: https://traefik.buq.duckdns.org"
}

show_logs() {
    echo "=== Service Logs ==="
    echo "Traefik logs:"
    docker logs traefik --tail=10
    echo ""
    echo "WG-Easy logs:"
    docker logs wg-easy --tail=10
}

traefik_start() {
    docker-compose -f traefik-compose.yml up -d
    echo "Traefik started!"
}

traefik_stop() {
    docker-compose -f traefik-compose.yml down
    echo "Traefik stopped!"
}

traefik_restart() {
    docker-compose -f traefik-compose.yml restart
    echo "Traefik restarted!"
}

traefik_logs() {
    docker logs traefik --tail=20 -f
}

wg_start() {
    docker-compose -f wg-easy-compose.yml up -d
    echo "WG-Easy started!"
}

wg_stop() {
    docker-compose -f wg-easy-compose.yml down
    echo "WG-Easy stopped!"
}

wg_restart() {
    docker-compose -f wg-easy-compose.yml restart
    echo "WG-Easy restarted!"
}

wg_logs() {
    docker logs wg-easy --tail=20 -f
}

update_dns() {
    echo "Updating Duck DNS IP..."
    CURRENT_IP=$(curl -s http://checkip.amazonaws.com)
    echo "Current IP: $CURRENT_IP"
    
    RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=$CURRENT_IP")
    
    if [ "$RESPONSE" = "OK" ]; then
        echo "✅ Duck DNS updated successfully!"
    else
        echo "❌ Error updating Duck DNS: $RESPONSE"
    fi
}

run_debug() {
    echo "Running debug script..."
    ./debug.sh
}

fix_v15() {
    echo "Running WG-Easy v15 migration fix..."
    ./fix-wg-v15.sh
}

cleanup() {
    echo "Cleaning up all containers and networks..."
    docker-compose -f wg-easy-compose.yml down -v
    docker-compose -f traefik-compose.yml down -v
    docker rm -f traefik wg-easy 2>/dev/null || true
    docker network rm traefik wg 2>/dev/null || true
    echo "Cleanup complete!"
}

# Main script logic
case "$1" in
    install-traefik) install_traefik ;;
    install-wg) install_wg ;;
    install-all) install_all ;;
    start) start_all ;;
    stop) stop_all ;;
    restart) restart_all ;;
    status) show_status ;;
    logs) show_logs ;;
    traefik-start) traefik_start ;;
    traefik-stop) traefik_stop ;;
    traefik-restart) traefik_restart ;;
    traefik-logs) traefik_logs ;;
    wg-start) wg_start ;;
    wg-stop) wg_stop ;;
    wg-restart) wg_restart ;;
    wg-logs) wg_logs ;;
    update-dns) update_dns ;;
    debug) run_debug ;;
    fix-v15) fix_v15 ;;
    cleanup) cleanup ;;
    help|--help|-h) show_help ;;
    "") echo "No command specified. Use '$0 help' for usage information." ;;
    *) echo "Unknown command: $1"; show_help; exit 1 ;;
esac
