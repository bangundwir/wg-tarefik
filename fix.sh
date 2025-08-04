#!/bin/bash

echo "=== WireGuard Easy Traefik Fix Script ==="
echo ""

# Stop all services
echo "1. Stopping all services..."
docker-compose down

# Remove any conflicting containers
echo "2. Removing any existing containers..."
docker rm -f traefik wg-easy 2>/dev/null || true

# Clean up any orphaned containers
echo "3. Cleaning up orphaned containers..."
docker container prune -f

# Ensure network exists
echo "4. Creating/checking Traefik network..."
docker network create traefik 2>/dev/null || echo "Network already exists"

# Set proper permissions
echo "5. Setting proper file permissions..."
chmod 600 traefik/acme.json
mkdir -p wg-easy

# Update Duck DNS IP
echo "6. Updating Duck DNS with current IP..."
CURRENT_IP=$(curl -s http://checkip.amazonaws.com)
if [ ! -z "$CURRENT_IP" ]; then
    echo "Current IP: $CURRENT_IP"
    RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=$CURRENT_IP")
    if [ "$RESPONSE" = "OK" ]; then
        echo "Duck DNS updated successfully!"
    else
        echo "Duck DNS update failed: $RESPONSE"
    fi
else
    echo "Could not get current IP"
fi

# Start services with fresh containers
echo "7. Starting services..."
docker-compose up -d

# Wait for services to start
echo "8. Waiting for services to start..."
sleep 10

# Check status
echo "9. Checking service status..."
docker-compose ps

echo ""
echo "=== Fix Complete ==="
echo ""
echo "Access URLs:"
echo "- WireGuard Easy: https://wg.buq.duckdns.org (Password: Arema123)"
echo "- Traefik Dashboard: https://traefik.buq.duckdns.org (admin:Arema123)"
echo ""
echo "If still not working, run: ./debug.sh"
