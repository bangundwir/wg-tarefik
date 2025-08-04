#!/bin/bash

echo "=== WG-Easy v15.1 Official Setup with Traefik ==="
echo ""
echo "Following official documentation from:"
echo "https://wg-easy.github.io/wg-easy/latest/examples/tutorials/traefik/"
echo ""

# Step 1: Create directories
echo "1. Creating directories..."
sudo mkdir -p /etc/docker/containers/traefik
sudo mkdir -p /etc/docker/containers/wg-easy
sudo mkdir -p /etc/docker/volumes/traefik

# Step 2: Copy files to official structure
echo "2. Setting up official directory structure..."

# Copy Traefik compose
sudo cp traefik-compose-official.yml /etc/docker/containers/traefik/docker-compose.yml

# Copy WG-Easy compose
sudo cp wg-easy-compose-official.yml /etc/docker/containers/wg-easy/docker-compose.yml

# Copy Traefik config files
sudo cp -r traefik/* /etc/docker/volumes/traefik/

# Step 3: Set permissions
echo "3. Setting permissions..."
sudo chmod 600 /etc/docker/volumes/traefik/acme.json

# Step 4: Create network
echo "4. Creating Traefik network..."
sudo docker network create traefik 2>/dev/null || echo "Network already exists"

# Step 5: Start Traefik
echo "5. Starting Traefik..."
cd /etc/docker/containers/traefik
sudo docker compose down 2>/dev/null || true
sudo docker compose pull
sudo docker compose up -d

# Wait for Traefik
echo "6. Waiting for Traefik to start..."
sleep 15

# Check Traefik
echo "7. Checking Traefik status..."
sudo docker compose ps

# Step 8: Start WG-Easy
echo ""
echo "8. Starting WG-Easy..."
cd /etc/docker/containers/wg-easy
sudo docker compose down 2>/dev/null || true
sudo docker compose pull
sudo docker compose up -d

# Wait for WG-Easy
echo "9. Waiting for WG-Easy to start..."
sleep 20

# Step 9: Check status
echo "10. Checking WG-Easy status..."
sudo docker compose ps

echo ""
echo "11. Checking logs..."
echo "--- Traefik logs ---"
cd /etc/docker/containers/traefik
sudo docker compose logs --tail=10

echo ""
echo "--- WG-Easy logs ---"
cd /etc/docker/containers/wg-easy
sudo docker compose logs --tail=10

echo ""
echo "=== Official Setup Complete! ==="
echo ""
echo "📋 Directory Structure (Official):"
echo "   /etc/docker/containers/traefik/docker-compose.yml"
echo "   /etc/docker/containers/wg-easy/docker-compose.yml"
echo "   /etc/docker/volumes/traefik/traefik.yml"
echo "   /etc/docker/volumes/traefik/traefik_dynamic.yml"
echo "   /etc/docker/volumes/traefik/acme.json"
echo ""
echo "🌐 Access URLs:"
echo "   - WG-Easy: https://wg.buq.duckdns.org"
echo "   - Traefik Dashboard: https://traefik.buq.duckdns.org"
echo ""
echo "🔐 Credentials:"
echo "   - Traefik Dashboard: admin / Arema123"
echo ""
echo "📱 Next Steps:"
echo "1. Access WG-Easy setup wizard: https://wg.buq.duckdns.org"
echo "2. Complete the initial setup in the web interface"
echo "3. Create VPN clients through the web UI"
echo ""
echo "🔧 Management Commands:"
echo "   cd /etc/docker/containers/traefik && sudo docker compose logs -f"
echo "   cd /etc/docker/containers/wg-easy && sudo docker compose logs -f"
echo "   cd /etc/docker/containers/traefik && sudo docker compose restart"
echo "   cd /etc/docker/containers/wg-easy && sudo docker compose restart"
