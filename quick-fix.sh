#!/bin/bash

# Quick Fix Script for WireGuard Easy + Traefik Issues

echo "🔧 Quick Fix for WireGuard Easy + Traefik"
echo ""

# Stop everything first
echo "1. Stopping all services..."
docker-compose down
docker rm -f traefik wg-easy 2>/dev/null || true

# Recreate networks
echo "2. Recreating Docker networks..."
docker network rm traefik wg 2>/dev/null || true
docker network create traefik
docker network create wg --driver bridge --enable-ipv6 \
  --subnet=10.42.42.0/24 \
  --ipv6 --subnet=fdcc:ad94:bacf:61a3::/64 2>/dev/null || \
  docker network create wg --driver bridge --subnet=10.42.42.0/24

# Fix file permissions
echo "3. Fixing file permissions..."
chmod 600 traefik/acme.json
mkdir -p wg-easy

# Update Duck DNS
echo "4. Updating Duck DNS..."
CURRENT_IP=$(curl -s http://checkip.amazonaws.com)
if [ ! -z "$CURRENT_IP" ]; then
    echo "Current public IP: $CURRENT_IP"
    RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=$CURRENT_IP")
    if [ "$RESPONSE" = "OK" ]; then
        echo "✅ Duck DNS updated successfully"
    else
        echo "⚠️  Duck DNS update response: $RESPONSE"
    fi
else
    echo "⚠️  Could not get public IP"
fi

# Start services
echo "5. Starting services..."
docker-compose up -d

# Wait a bit for services to start
echo "6. Waiting for services to start..."
sleep 10

# Check status
echo "7. Checking service status..."
docker-compose ps

echo ""
echo "8. Testing connectivity..."
sleep 5

# Test if WG-Easy is responding internally
WG_CONTAINER_IP=$(docker inspect wg-easy --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
if [ ! -z "$WG_CONTAINER_IP" ]; then
    echo "Testing WG-Easy internal access..."
    curl -s -m 5 http://$WG_CONTAINER_IP:51821 > /dev/null && echo "✅ WG-Easy responding internally" || echo "❌ WG-Easy not responding internally"
fi

echo ""
echo "🎉 Quick fix complete!"
echo ""
echo "Now try accessing:"
echo "- WireGuard Easy: https://wg.buq.duckdns.org"
echo "- Traefik Dashboard: https://traefik.buq.duckdns.org (admin:Arema123)"
echo ""
echo "If still not working, run: ./troubleshoot.sh"
echo ""
echo "Note: SSL certificates may take 1-2 minutes to generate."
echo "If you see certificate errors, wait a moment and try again."
