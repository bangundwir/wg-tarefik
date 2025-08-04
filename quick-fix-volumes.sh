#!/bin/bash

echo "=== Quick Fix for Traefik Volume Issue ==="
echo ""

# Stop services
echo "1. Stopping all services..."
sudo docker stop traefik wg-easy 2>/dev/null || true
sudo docker rm traefik wg-easy 2>/dev/null || true

# Clean up problematic directories
echo "2. Cleaning up volume mounts..."
sudo rm -rf /etc/docker/volumes/traefik/traefik.yml
sudo rm -rf /etc/docker/volumes/traefik/traefik_dynamic.yml
sudo rm -rf /etc/docker/volumes/traefik/acme.json

# Ensure directory exists
sudo mkdir -p /etc/docker/volumes/traefik

# Copy files correctly
echo "3. Copying configuration files..."
sudo cp traefik/traefik.yml /etc/docker/volumes/traefik/ 2>/dev/null || echo "traefik.yml not found in current dir"
sudo cp traefik/traefik_dynamic.yml /etc/docker/volumes/traefik/ 2>/dev/null || echo "traefik_dynamic.yml not found in current dir"

# Create acme.json
sudo touch /etc/docker/volumes/traefik/acme.json
sudo chmod 600 /etc/docker/volumes/traefik/acme.json

# Verify files are actually files, not directories
echo "4. Verifying files..."
if [ -f "/etc/docker/volumes/traefik/traefik.yml" ]; then
    echo "   ✅ traefik.yml is a file"
else
    echo "   ❌ traefik.yml missing or not a file"
fi

if [ -f "/etc/docker/volumes/traefik/traefik_dynamic.yml" ]; then
    echo "   ✅ traefik_dynamic.yml is a file"
else
    echo "   ❌ traefik_dynamic.yml missing or not a file"
fi

if [ -f "/etc/docker/volumes/traefik/acme.json" ]; then
    echo "   ✅ acme.json is a file"
else
    echo "   ❌ acme.json missing or not a file"
fi

echo ""
echo "✅ Quick fix complete!"
echo ""
echo "Now run the official setup:"
echo "./manage-official.sh start-all"
echo ""
echo "Or manually:"
echo "cd /etc/docker/containers/traefik && sudo docker compose up -d"
echo "cd /etc/docker/containers/wg-easy && sudo docker compose up -d"
