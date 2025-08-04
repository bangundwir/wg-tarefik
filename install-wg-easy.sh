#!/bin/bash

echo "=== Installing WG-Easy ==="
echo ""

# Step 1: Check if Traefik is running
echo "1. Checking if Traefik is running..."
if ! docker ps | grep -q "traefik"; then
    echo "❌ Traefik is not running! Please run './install-traefik.sh' first"
    exit 1
fi
echo "✅ Traefik is running"

# Step 2: Stop any existing WG-Easy
echo "2. Stopping any existing WG-Easy..."
docker-compose -f wg-easy-compose.yml down 2>/dev/null || true
docker rm -f wg-easy 2>/dev/null || true

# Step 3: Create WG network
echo "3. Creating WG network..."
# WG network will be created by docker-compose

# Step 4: Pull WG-Easy image
echo "4. Pulling WG-Easy image..."
docker-compose -f wg-easy-compose.yml pull

# Step 5: Start WG-Easy
echo "5. Starting WG-Easy..."
docker-compose -f wg-easy-compose.yml up -d

# Step 6: Wait for WG-Easy to start
echo "6. Waiting for WG-Easy to start..."
sleep 15

# Step 7: Check status
echo "7. Checking WG-Easy status..."
docker-compose -f wg-easy-compose.yml ps

echo ""
echo "8. Checking WG-Easy logs..."
docker logs wg-easy --tail=15

echo ""
echo "9. Testing internal connectivity..."
sleep 5
docker exec traefik wget -q --spider http://wg-easy:51821 && echo "✅ WG-Easy reachable from Traefik" || echo "❌ WG-Easy NOT reachable from Traefik"

echo ""
echo "=== WG-Easy Installation Complete ==="
echo ""
echo "Access URLs:"
echo "- WireGuard Easy: https://wg.buq.duckdns.org"
echo "- Traefik Dashboard: https://traefik.buq.duckdns.org"
echo "- Direct access (for testing): http://$(curl -s http://checkip.amazonaws.com):51821"
echo ""
echo "Credentials:"
echo "- Username: admin (for Traefik dashboard)"
echo "- Password: Arema123 (for both services)"
echo ""
echo "Important notes:"
echo "1. Wait 2-3 minutes for SSL certificates if accessing for the first time"
echo "2. Make sure ports 80, 443, and 51820 are open in your firewall"
echo "3. Ensure both domains point to your server IP"

echo ""
echo "Troubleshooting:"
echo "- View logs: docker logs wg-easy"
echo "- Restart WG-Easy: docker-compose -f wg-easy-compose.yml restart"
echo "- Debug script: ./debug.sh"
