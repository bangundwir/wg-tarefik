#!/bin/bash

# WireGuard Easy with Traefik Management Script

show_help() {
    echo "WireGuard Easy with Traefik Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start     Start all services"
    echo "  stop      Stop all services"
    echo "  restart   Restart all services"
    echo "  status    Show services status"
    echo "  logs      Show services logs"
    echo "  update    Update Duck DNS IP"
    echo "  backup    Backup WireGuard configuration"
    echo "  restore   Restore WireGuard configuration"
    echo "  help      Show this help message"
    echo ""
}

start_services() {
    echo "Starting WireGuard Easy with Traefik..."
    docker-compose up -d
    echo "Services started!"
    show_status
}

stop_services() {
    echo "Stopping services..."
    docker-compose down
    echo "Services stopped!"
}

restart_services() {
    echo "Restarting services..."
    docker-compose restart
    echo "Services restarted!"
    show_status
}

show_status() {
    echo ""
    echo "Service Status:"
    docker-compose ps
    echo ""
    echo "Access URLs:"
    echo "- WireGuard Easy: https://wg.buq.duckdns.org"
    echo "- Traefik Dashboard: https://traefik.buq.duckdns.org"
}

show_logs() {
    echo "Showing logs (Press Ctrl+C to exit)..."
    docker-compose logs -f
}

update_duckdns() {
    echo "Updating Duck DNS IP..."
    # Get current public IP
    CURRENT_IP=$(curl -s http://checkip.amazonaws.com)
    
    if [ -z "$CURRENT_IP" ]; then
        echo "Error: Could not get current public IP"
        exit 1
    fi
    
    echo "Current public IP: $CURRENT_IP"
    
    # Update Duck DNS
    RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=$CURRENT_IP")
    
    if [ "$RESPONSE" = "OK" ]; then
        echo "Duck DNS updated successfully!"
    else
        echo "Error updating Duck DNS: $RESPONSE"
        exit 1
    fi
}

backup_config() {
    BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup in $BACKUP_DIR..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup WireGuard configuration
    if [ -d "wg-easy" ]; then
        cp -r wg-easy "$BACKUP_DIR/"
        echo "WireGuard configuration backed up"
    fi
    
    # Backup Traefik configuration
    cp -r traefik "$BACKUP_DIR/"
    cp docker-compose.yml "$BACKUP_DIR/"
    
    echo "Backup created successfully in $BACKUP_DIR"
}

restore_config() {
    echo "Available backups:"
    ls -la backups/ 2>/dev/null || { echo "No backups found"; exit 1; }
    
    echo ""
    read -p "Enter backup directory name (e.g., 20250805_143000): " BACKUP_NAME
    
    BACKUP_PATH="backups/$BACKUP_NAME"
    
    if [ ! -d "$BACKUP_PATH" ]; then
        echo "Backup directory not found: $BACKUP_PATH"
        exit 1
    fi
    
    echo "Stopping services..."
    docker-compose down
    
    echo "Restoring configuration..."
    
    # Restore WireGuard configuration
    if [ -d "$BACKUP_PATH/wg-easy" ]; then
        rm -rf wg-easy
        cp -r "$BACKUP_PATH/wg-easy" ./
        echo "WireGuard configuration restored"
    fi
    
    # Restore Traefik configuration
    cp -r "$BACKUP_PATH/traefik" ./
    cp "$BACKUP_PATH/docker-compose.yml" ./
    
    echo "Configuration restored successfully"
    echo "Starting services..."
    docker-compose up -d
}

# Main script logic
case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    update)
        update_duckdns
        ;;
    backup)
        backup_config
        ;;
    restore)
        restore_config
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        echo "No command specified. Use '$0 help' for usage information."
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
