#!/bin/bash

echo "=== WireGuard Easy + Traefik Troubleshooting ==="
echo ""

# Check if containers are running
echo "1. Checking container status..."
echo "Traefik:"
docker-compose -f traefik-compose.yml ps
echo ""
echo "WG-Easy:"
docker-compose -f wg-easy-compose.yml ps
echo ""

echo "2. Checking Docker networks..."
docker network ls | grep -E "(traefik|wg)"
echo ""

echo "3. Checking if containers are in correct networks..."
echo "Traefik networks:"
docker inspect traefik | grep -A 10 '"Networks"'
echo ""
echo "WG-Easy networks:"
docker inspect wg-easy | grep -A 10 '"Networks"'
echo ""

echo "4. Checking Traefik logs (last 20 lines)..."
docker logs traefik --tail=20
echo ""

echo "5. Checking WG-Easy logs (last 20 lines)..."
docker logs wg-easy --tail=20
echo ""

echo "6. Testing internal connectivity..."
docker exec traefik wget -q --spider http://wg-easy:51821 && echo "✓ WG-Easy reachable from Traefik" || echo "✗ WG-Easy NOT reachable from Traefik"
echo ""

echo "7. Checking ports..."
docker exec wg-easy netstat -tlnp | grep 51821 || echo "Port 51821 not listening in wg-easy container"
echo ""

echo "8. Testing DNS resolution..."
nslookup wg.buq.duckdns.org || echo "DNS resolution failed"
echo ""

echo "9. Checking Duck DNS status..."
curl -s "https://www.duckdns.org/domains" | grep -i buq || echo "Cannot check Duck DNS status"
echo ""

echo "10. Direct access test..."
echo "Try accessing directly: http://$(curl -s http://checkip.amazonaws.com):51821"
echo ""

echo "=== Traefik Router Configuration ==="
docker exec traefik cat /etc/traefik/traefik.yml | grep -A 50 "entryPoints" || echo "Cannot read Traefik config"

# Check Docker networks
echo "2. Checking Docker networks..."
docker network ls | grep traefik
echo ""

# Check Traefik logs
echo "3. Checking Traefik logs (last 20 lines)..."
docker-compose logs --tail=20 traefik
echo ""

# Check WireGuard Easy logs
echo "4. Checking WireGuard Easy logs (last 20 lines)..."
docker-compose logs --tail=20 wg-easy
echo ""

# Check if ports are listening
echo "5. Checking if ports are open..."
echo "Port 80 (HTTP):"
netstat -ln | grep :80 || echo "Port 80 not listening"
echo "Port 443 (HTTPS):"
netstat -ln | grep :443 || echo "Port 443 not listening"
echo "Port 51820 (WireGuard):"
netstat -ln | grep :51820 || echo "Port 51820 not listening"
echo "Port 51821 (WG Web):"
netstat -ln | grep :51821 || echo "Port 51821 not listening"
echo ""

# Check DNS resolution
echo "6. Testing DNS resolution..."
nslookup wg.buq.duckdns.org || echo "DNS resolution failed"
nslookup traefik.buq.duckdns.org || echo "DNS resolution failed"
echo ""

# Check if we can reach WireGuard directly
echo "7. Testing direct access to WireGuard Easy..."
curl -I http://localhost:51821 2>/dev/null || echo "Cannot reach WireGuard Easy directly"
echo ""

# Show Traefik configuration
echo "8. Traefik router information..."
curl -s http://localhost:8080/api/http/routers 2>/dev/null | grep -E "rule|service|status" || echo "Cannot access Traefik API"
echo ""

echo "=== Debug Complete ==="
echo ""
echo "Common fixes:"
echo "1. Restart services: docker-compose restart"
echo "2. Check firewall: sudo ufw status"
echo "3. Update DNS: ./update-duckdns.sh"
echo "4. Clean restart: docker-compose down && docker-compose up -d"
