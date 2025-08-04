#!/bin/bash

echo "=== WireGuard Easy Fix Script ==="
echo ""

# Step 1: Stop everything
echo "1. Stopping all services..."
docker-compose down
docker rm -f traefik wg-easy 2>/dev/null || true

# Step 2: Create networks
echo "2. Creating networks..."
docker network create traefik 2>/dev/null || echo "Traefik network already exists"

# Step 3: Set permissions
echo "3. Setting permissions..."
chmod 600 traefik/acme.json
mkdir -p wg-easy

# Step 4: Pull latest images
echo "4. Pulling latest images..."
docker-compose pull

# Step 5: Start services
echo "5. Starting services..."
docker-compose up -d

# Wait a bit for services to start
echo "6. Waiting for services to start..."
sleep 10

# Step 6: Check status
echo "7. Checking status..."
docker-compose ps

echo ""
echo "8. Checking logs..."
echo "--- Traefik logs ---"
docker logs traefik --tail=10

echo ""
echo "--- WG-Easy logs ---"
docker logs wg-easy --tail=10

echo ""
echo "=== Access Information ==="
echo "WireGuard Easy: https://wg.buq.duckdns.org"
echo "Traefik Dashboard: https://traefik.buq.duckdns.org"
echo "Username: admin"
echo "Password: Arema123"
echo ""
echo "Direct access (for testing): http://YOUR_SERVER_IP:51821"
echo ""

# Test internal connectivity
echo "=== Testing Internal Connectivity ==="
sleep 5
docker exec traefik wget -q --spider http://wg-easy:51821 && echo "✓ WG-Easy reachable from Traefik" || echo "✗ WG-Easy NOT reachable from Traefik"
