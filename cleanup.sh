#!/bin/bash

# Clean up script for WireGuard Easy with Traefik

echo "Cleaning up existing containers and networks..."

# Stop and remove containers using docker-compose
echo "Stopping services with docker-compose..."
docker-compose down 2>/dev/null || true

# Force remove individual containers if they still exist
echo "Removing individual containers..."
docker rm -f traefik wg-easy 2>/dev/null || true

# Remove any dangling images (optional)
echo "Removing unused Docker images..."
docker image prune -f

# Remove unused volumes (optional - be careful with this)
read -p "Do you want to remove unused Docker volumes? This will delete all WireGuard configurations! (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker volume prune -f
    echo "Volumes removed. All WireGuard configurations are deleted!"
else
    echo "Volumes kept. WireGuard configurations preserved."
fi

# Remove unused networks
echo "Removing unused Docker networks..."
docker network prune -f

echo ""
echo "Cleanup complete!"
echo "You can now run ./setup.sh to start fresh."
