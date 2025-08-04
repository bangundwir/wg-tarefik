#!/bin/bash

echo "=== WG-Easy v15 Migration Fix ==="
echo ""

# Step 1: Stop and remove old containers
echo "1. Stopping and removing old WG-Easy containers..."
docker-compose -f wg-easy-compose.yml down -v 2>/dev/null || true
docker rm -f wg-easy 2>/dev/null || true

# Step 2: Remove old volumes (this will reset WG-Easy configuration)
echo "2. Removing old WG-Easy volumes and configuration..."
docker volume rm wg-easy_etc_wireguard 2>/dev/null || echo "Volume already removed or doesn't exist"

# Step 3: Clean up old data directory if exists
echo "3. Cleaning up old configuration..."
rm -rf wg-easy/ 2>/dev/null || true

# Step 4: Recreate networks
echo "4. Recreating networks..."
docker network rm wg 2>/dev/null || true

# Step 5: Pull latest image
echo "5. Pulling WG-Easy v15 image..."
docker-compose -f wg-easy-compose.yml pull

# Step 6: Start WG-Easy with clean configuration
echo "6. Starting WG-Easy v15 with clean configuration..."
docker-compose -f wg-easy-compose.yml up -d

# Step 7: Wait for startup
echo "7. Waiting for WG-Easy to start (30 seconds)..."
sleep 30

# Step 8: Check status
echo "8. Checking WG-Easy status..."
docker-compose -f wg-easy-compose.yml ps

echo ""
echo "9. Checking WG-Easy logs..."
docker logs wg-easy --tail=20

echo ""
echo "10. Testing internal connectivity..."
docker exec traefik wget -q --spider http://wg-easy:51821 && echo "✅ WG-Easy reachable from Traefik" || echo "❌ WG-Easy NOT reachable from Traefik"

echo ""
echo "=== WG-Easy v15 Setup Complete ==="
echo ""
echo "🎉 WG-Easy v15 is now running with clean configuration!"
echo ""
echo "📋 Next Steps:"
echo "1. Access WG-Easy at: https://wg.buq.duckdns.org"
echo "2. Complete the setup wizard in the Web UI"
echo "3. Configure your WireGuard settings in the Admin Panel"
echo ""
echo "🔧 Important Notes for v15:"
echo "- Most configuration is now done through the Web UI Admin Panel"
echo "- Environment variables like WG_HOST, PASSWORD, etc. are no longer used"
echo "- You'll need to configure server settings through the web interface"
echo ""
echo "🌐 Access URLs:"
echo "- WG-Easy Web UI: https://wg.buq.duckdns.org"
echo "- Traefik Dashboard: https://traefik.buq.duckdns.org"
echo "- Direct access: http://$(curl -s http://checkip.amazonaws.com):51821"
echo ""
echo "🔐 If accessing via HTTP (direct access), you may need to set INSECURE=true"
