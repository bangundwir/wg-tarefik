#!/bin/bash

echo "=== Fixing Traefik Volume Mounting Issue ==="
echo ""

# Stop all services first
echo "1. Stopping services..."
cd /etc/docker/containers/traefik 2>/dev/null && sudo docker compose down
cd /etc/docker/containers/wg-easy 2>/dev/null && sudo docker compose down

# Remove containers
echo "2. Removing containers..."
sudo docker rm -f traefik wg-easy 2>/dev/null || true

# Check and fix file permissions and structure
echo "3. Checking file structure..."

# Ensure the files exist and are actual files, not directories
if [ -d "/etc/docker/volumes/traefik/traefik.yml" ]; then
    echo "   ERROR: traefik.yml is a directory, should be a file!"
    sudo rm -rf /etc/docker/volumes/traefik/traefik.yml
fi

if [ -d "/etc/docker/volumes/traefik/traefik_dynamic.yml" ]; then
    echo "   ERROR: traefik_dynamic.yml is a directory, should be a file!"
    sudo rm -rf /etc/docker/volumes/traefik/traefik_dynamic.yml
fi

if [ -d "/etc/docker/volumes/traefik/acme.json" ]; then
    echo "   ERROR: acme.json is a directory, should be a file!"
    sudo rm -rf /etc/docker/volumes/traefik/acme.json
fi

# Create directory structure
echo "4. Creating proper directory structure..."
sudo mkdir -p /etc/docker/volumes/traefik
sudo mkdir -p /etc/docker/containers/traefik
sudo mkdir -p /etc/docker/containers/wg-easy

# Copy configuration files properly
echo "5. Copying configuration files..."
if [ -f "traefik/traefik.yml" ]; then
    sudo cp traefik/traefik.yml /etc/docker/volumes/traefik/
    echo "   ✅ Copied traefik.yml"
else
    echo "   ❌ traefik/traefik.yml not found in current directory"
fi

if [ -f "traefik/traefik_dynamic.yml" ]; then
    sudo cp traefik/traefik_dynamic.yml /etc/docker/volumes/traefik/
    echo "   ✅ Copied traefik_dynamic.yml"
else
    echo "   ❌ traefik/traefik_dynamic.yml not found in current directory"
fi

# Create acme.json properly
echo "6. Creating acme.json..."
sudo touch /etc/docker/volumes/traefik/acme.json
sudo chmod 600 /etc/docker/volumes/traefik/acme.json
echo "   ✅ Created acme.json with proper permissions"

# Copy docker-compose files
echo "7. Copying Docker Compose files..."
if [ -f "traefik-compose-official.yml" ]; then
    sudo cp traefik-compose-official.yml /etc/docker/containers/traefik/docker-compose.yml
    echo "   ✅ Copied Traefik docker-compose.yml"
else
    echo "   ❌ traefik-compose-official.yml not found"
fi

if [ -f "wg-easy-compose-official.yml" ]; then
    sudo cp wg-easy-compose-official.yml /etc/docker/containers/wg-easy/docker-compose.yml
    echo "   ✅ Copied WG-Easy docker-compose.yml"
else
    echo "   ❌ wg-easy-compose-official.yml not found"
fi

# Verify file structure
echo ""
echo "8. Verifying file structure..."
echo "Checking /etc/docker/volumes/traefik/:"
ls -la /etc/docker/volumes/traefik/ | grep -E "\.(yml|json)$"

echo ""
echo "File types:"
file /etc/docker/volumes/traefik/traefik.yml 2>/dev/null || echo "traefik.yml: not found"
file /etc/docker/volumes/traefik/traefik_dynamic.yml 2>/dev/null || echo "traefik_dynamic.yml: not found"
file /etc/docker/volumes/traefik/acme.json 2>/dev/null || echo "acme.json: not found"

# Create network
echo ""
echo "9. Creating network..."
sudo docker network create traefik 2>/dev/null || echo "Network already exists"

# Start Traefik first
echo ""
echo "10. Starting Traefik..."
cd /etc/docker/containers/traefik
sudo docker compose up -d

# Wait and check
echo ""
echo "11. Waiting 10 seconds and checking Traefik..."
sleep 10
sudo docker compose ps
echo ""
echo "Traefik logs:"
sudo docker compose logs --tail=5

# If Traefik is working, start WG-Easy
if sudo docker ps | grep -q "traefik"; then
    echo ""
    echo "12. Traefik is running, starting WG-Easy..."
    cd /etc/docker/containers/wg-easy
    sudo docker compose up -d
    
    echo ""
    echo "13. Checking WG-Easy..."
    sleep 10
    sudo docker compose ps
    echo ""
    echo "WG-Easy logs:"
    sudo docker compose logs --tail=5
else
    echo ""
    echo "❌ Traefik failed to start. Check the logs above."
    exit 1
fi

echo ""
echo "=== Fix Complete! ==="
echo ""
echo "🎉 Services should now be running properly!"
echo ""
echo "🌐 Access URLs:"
echo "   - WG-Easy: https://wg.buq.duckdns.org"
echo "   - Traefik Dashboard: https://traefik.buq.duckdns.org"
echo ""
echo "🔧 Management commands:"
echo "   cd /etc/docker/containers/traefik && sudo docker compose logs -f"
echo "   cd /etc/docker/containers/wg-easy && sudo docker compose logs -f"
