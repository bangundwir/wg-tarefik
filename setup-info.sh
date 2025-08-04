#!/bin/bash

echo "=== WG-Easy v15 Setup Information ==="
echo ""

# Get current public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo "Unable to get IP")

echo "📋 Setup Information for WG-Easy v15:"
echo ""
echo "🌐 Host/Domain:"
echo "   wg.buq.duckdns.org"
echo ""
echo "🔌 WireGuard Port:"
echo "   51820"
echo ""
echo "🖥️ Current Public IP:"
echo "   $PUBLIC_IP"
echo ""
echo "🔐 Suggested Admin Password:"
echo "   Arema123"
echo ""
echo "🌍 Suggested Network Settings:"
echo "   VPN Network: 10.8.0.0/24"
echo "   DNS Servers: 1.1.1.1, 8.8.8.8"
echo ""
echo "📡 Access URLs:"
echo "   Setup: https://wg.buq.duckdns.org"
echo "   Traefik: https://traefik.buq.duckdns.org"
echo ""

# Check if WG-Easy is accessible
echo "🔍 Testing WG-Easy accessibility..."
if curl -s -k https://wg.buq.duckdns.org > /dev/null 2>&1; then
    echo "   ✅ WG-Easy is accessible via HTTPS"
elif curl -s http://wg.buq.duckdns.org > /dev/null 2>&1; then
    echo "   ✅ WG-Easy is accessible via HTTP"
else
    echo "   ❌ WG-Easy not accessible - check DNS/Firewall"
fi

# Check DNS
echo ""
echo "🔍 DNS Check:"
DNS_IP=$(nslookup wg.buq.duckdns.org 2>/dev/null | grep "Address:" | tail -1 | awk '{print $2}')
if [ "$DNS_IP" = "$PUBLIC_IP" ]; then
    echo "   ✅ DNS correctly points to your server ($DNS_IP)"
elif [ -n "$DNS_IP" ]; then
    echo "   ⚠️  DNS points to $DNS_IP, but server IP is $PUBLIC_IP"
    echo "   💡 Update Duck DNS if needed:"
    echo "      curl \"https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=$PUBLIC_IP\""
else
    echo "   ❌ DNS resolution failed"
fi

echo ""
echo "🚀 Next Steps:"
echo "1. Complete the setup wizard at: https://wg.buq.duckdns.org"
echo "2. Use the Host: wg.buq.duckdns.org"
echo "3. Use the Port: 51820"
echo "4. Set admin password (suggested: Arema123)"
echo "5. Configure network settings as needed"
echo ""
echo "📞 If you need help:"
echo "   - View logs: docker logs wg-easy"
echo "   - Check status: ./manage-services.sh status"
echo "   - Debug: ./debug.sh"
