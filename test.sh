#!/bin/bash

echo "=== Testing WireGuard Easy Access ==="
echo ""

# Test 1: Check if WireGuard Easy is responding locally
echo "1. Testing local WireGuard Easy access..."
if curl -s -I http://localhost:51821 > /dev/null 2>&1; then
    echo "✓ WireGuard Easy is responding locally on port 51821"
else
    echo "✗ WireGuard Easy is NOT responding locally on port 51821"
    echo "  Check if container is running: docker-compose ps"
fi
echo ""

# Test 2: Check if Traefik is responding
echo "2. Testing local Traefik access..."
if curl -s -I http://localhost:80 > /dev/null 2>&1; then
    echo "✓ Traefik is responding on port 80"
else
    echo "✗ Traefik is NOT responding on port 80"
fi

if curl -s -I http://localhost:443 > /dev/null 2>&1; then
    echo "✓ Traefik is responding on port 443"
else
    echo "✗ Traefik is NOT responding on port 443"
fi
echo ""

# Test 3: Check DNS resolution
echo "3. Testing DNS resolution..."
WG_IP=$(nslookup wg.buq.duckdns.org | grep -A1 "Name:" | tail -1 | awk '{print $2}')
TRAEFIK_IP=$(nslookup traefik.buq.duckdns.org | grep -A1 "Name:" | tail -1 | awk '{print $2}')
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

echo "wg.buq.duckdns.org resolves to: $WG_IP"
echo "traefik.buq.duckdns.org resolves to: $TRAEFIK_IP"
echo "Your public IP is: $PUBLIC_IP"

if [ "$WG_IP" = "$PUBLIC_IP" ]; then
    echo "✓ DNS is correctly pointing to your server"
else
    echo "✗ DNS is NOT pointing to your server"
    echo "  Update Duck DNS: curl 'https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=$PUBLIC_IP'"
fi
echo ""

# Test 4: Test HTTPS access
echo "4. Testing HTTPS access..."
if curl -k -s -I https://wg.buq.duckdns.org > /dev/null 2>&1; then
    echo "✓ https://wg.buq.duckdns.org is accessible"
else
    echo "✗ https://wg.buq.duckdns.org is NOT accessible"
    echo "  This could be due to:"
    echo "  - DNS not updated"
    echo "  - Firewall blocking ports"
    echo "  - SSL certificate not ready"
fi

if curl -k -s -I https://traefik.buq.duckdns.org > /dev/null 2>&1; then
    echo "✓ https://traefik.buq.duckdns.org is accessible"
else
    echo "✗ https://traefik.buq.duckdns.org is NOT accessible"
fi
echo ""

# Test 5: Check container logs for errors
echo "5. Checking for common errors in logs..."
echo "Traefik errors:"
docker-compose logs traefik 2>/dev/null | grep -i error | tail -3 || echo "No recent errors found"
echo ""
echo "WireGuard Easy errors:"
docker-compose logs wg-easy 2>/dev/null | grep -i error | tail -3 || echo "No recent errors found"
echo ""

echo "=== Testing Complete ==="
echo ""
echo "Quick fixes to try:"
echo "1. Restart services: docker-compose restart"
echo "2. Clean restart: docker-compose down && docker-compose up -d"
echo "3. Update DNS: ./update-duckdns.sh"
echo "4. Check firewall: sudo ufw status"
echo "5. Wait for SSL certificate (can take 1-2 minutes)"
