#!/bin/bash

echo "Setting up WireGuard Easy with Traefik..."

# Create Docker network
echo "Creating Docker networks..."
docker network create traefik 2>/dev/null || echo "Traefik network already exists"
docker network create wg 2>/dev/null || echo "WG network already exists"

# Set proper permissions for acme.json
echo "Setting permissions for acme.json..."
chmod 600 traefik/acme.json

# Create wg-easy data directory
echo "Creating WireGuard data directory..."
mkdir -p wg-easy

# Stop and remove existing containers if they exist
echo "Stopping existing containers..."
docker-compose down 2>/dev/null || true

# Remove any orphaned containers with the same names
echo "Removing any existing containers..."
docker rm -f traefik wg-easy 2>/dev/null || true

# Pull latest images
echo "Pulling latest images (Traefik v3.5.0)..."
docker-compose pull

echo "Starting services..."
docker-compose up -d

echo ""
echo "Setup complete!"
echo ""
echo "Services:"
echo "- WireGuard Easy: https://wg.buq.duckdns.org"
echo "- Traefik Dashboard: https://traefik.buq.duckdns.org (admin:Arema123)"
echo ""
echo "Make sure to:"
echo "1. Point wg.buq.duckdns.org and traefik.buq.duckdns.org to your server IP"
echo "2. Ensure ports 80, 443, and 51820 are open in your firewall"
echo "3. Update Duck DNS with your current IP address using token: dfe377ca-478f-4f48-9d9d-3abbc069f5c0"
echo ""
echo "Useful commands:"
echo "- Check status: docker-compose ps"
echo "- View logs: docker-compose logs -f"
echo "- Restart services: docker-compose restart"
echo "- Stop services: docker-compose down"
echo ""
echo "Press any key to continue..."
read -n 1 -s
