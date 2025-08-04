#!/bin/bash

# WireGuard Easy Troubleshooting Script

echo "=== WireGuard Easy & Traefik Troubleshooting ==="
echo ""

# Check if Docker is running
echo "1. Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    exit 1
else
    echo "✅ Docker is running"
fi

# Check if containers are running
echo ""
echo "2. Checking container status..."
docker-compose ps

# Check networks
echo ""
echo "3. Checking Docker networks..."
echo "Traefik network:"
docker network inspect traefik 2>/dev/null | grep -A 5 "Name\|Containers" || echo "❌ Traefik network not found"

echo ""
echo "WG network:"
docker network inspect $(docker-compose ps -q | head -1 | xargs docker inspect --format='{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}' 2>/dev/null) 2>/dev/null | grep -A 5 "Name" || echo "WG network info not available"

# Check Traefik logs
echo ""
echo "4. Checking Traefik logs (last 20 lines)..."
docker-compose logs --tail=20 traefik

# Check WG-Easy logs
echo ""
echo "5. Checking WG-Easy logs (last 20 lines)..."
docker-compose logs --tail=20 wg-easy

# Check if ports are listening
echo ""
echo "6. Checking port status..."
echo "Port 80 (HTTP):"
netstat -tuln | grep :80 || echo "Port 80 not listening"

echo "Port 443 (HTTPS):"
netstat -tuln | grep :443 || echo "Port 443 not listening"

echo "Port 51820 (WireGuard):"
netstat -tuln | grep :51820 || echo "Port 51820 not listening"

echo "Port 51821 (WG-Easy Web):"
netstat -tuln | grep :51821 || echo "Port 51821 not listening"

# Test internal connectivity
echo ""
echo "7. Testing internal connectivity..."
WG_CONTAINER_IP=$(docker inspect wg-easy --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
if [ ! -z "$WG_CONTAINER_IP" ]; then
    echo "WG-Easy container IP: $WG_CONTAINER_IP"
    echo "Testing connection to WG-Easy web interface..."
    curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://$WG_CONTAINER_IP:51821 || echo "❌ Cannot connect to WG-Easy web interface"
else
    echo "❌ Cannot get WG-Easy container IP"
fi

# Check DNS resolution
echo ""
echo "8. Testing DNS resolution..."
nslookup wg.buq.duckdns.org || echo "❌ DNS resolution failed for wg.buq.duckdns.org"
nslookup traefik.buq.duckdns.org || echo "❌ DNS resolution failed for traefik.buq.duckdns.org"

# Check public IP
echo ""
echo "9. Checking public IP..."
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
echo "Current public IP: $PUBLIC_IP"

# Test external connectivity
echo ""
echo "10. Testing external connectivity..."
echo "Testing HTTP redirect (should redirect to HTTPS)..."
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://wg.buq.duckdns.org || echo "❌ HTTP test failed"

echo ""
echo "Testing HTTPS (may fail if SSL not ready)..."
curl -s -k -o /dev/null -w "HTTP Status: %{http_code}\n" https://wg.buq.duckdns.org || echo "❌ HTTPS test failed"

echo ""
echo "=== Troubleshooting Complete ==="
echo ""
echo "Common issues and solutions:"
echo "1. If containers are not running: Run 'docker-compose up -d'"
echo "2. If DNS fails: Update Duck DNS IP or check domain configuration"
echo "3. If SSL fails: Wait for Let's Encrypt certificate generation (can take a few minutes)"
echo "4. If ports are not listening: Check firewall settings"
echo "5. If Traefik can't reach WG-Easy: Check network configuration"
echo ""
echo "Manual tests you can run:"
echo "- Check Traefik dashboard: https://traefik.buq.duckdns.org"
echo "- Check WG-Easy directly: http://YOUR_SERVER_IP:51821"
echo "- Check WG-Easy via Traefik: https://wg.buq.duckdns.org"
