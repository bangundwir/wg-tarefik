#!/bin/bash

echo "=== Installing Traefik First ==="
echo ""

# Step 1: Create network
echo "1. Creating Traefik network..."
docker network create traefik 2>/dev/null || echo "Traefik network already exists"

# Step 2: Setup directories and permissions
echo "2. Setting up Traefik configuration..."
mkdir -p traefik
chmod 600 traefik/acme.json 2>/dev/null || echo "acme.json already has correct permissions"

# Step 3: Stop any existing Traefik
echo "3. Stopping any existing Traefik..."
docker-compose -f traefik-compose.yml down 2>/dev/null || true
docker rm -f traefik 2>/dev/null || true

# Step 4: Pull Traefik image
echo "4. Pulling Traefik v3.5.0 image..."
docker-compose -f traefik-compose.yml pull

# Step 5: Start Traefik
echo "5. Starting Traefik..."
docker-compose -f traefik-compose.yml up -d

# Step 6: Wait for Traefik to start
echo "6. Waiting for Traefik to start..."
sleep 10

# Step 7: Check Traefik status
echo "7. Checking Traefik status..."
docker-compose -f traefik-compose.yml ps

echo ""
echo "8. Checking Traefik logs..."
docker logs traefik --tail=15

echo ""
echo "=== Traefik Installation Complete ==="
echo ""
echo "Traefik Dashboard: https://traefik.buq.duckdns.org"
echo "Username: admin"
echo "Password: Arema123"
echo ""
echo "Next steps:"
echo "1. Make sure wg.buq.duckdns.org and traefik.buq.duckdns.org point to your server IP"
echo "2. Wait 2-3 minutes for SSL certificates to be generated"
echo "3. Access Traefik dashboard to verify it's working"
echo "4. Run './install-wg-easy.sh' to install WG-Easy"
echo ""

# Test DNS resolution
echo "Testing DNS resolution..."
nslookup traefik.buq.duckdns.org || echo "⚠️  DNS not resolved yet"

echo ""
echo "Update Duck DNS IP if needed:"
echo "curl \"https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=\$(curl -s http://checkip.amazonaws.com)\""
