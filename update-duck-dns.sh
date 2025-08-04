#!/bin/bash

echo "=== Duck DNS Update Script ==="
echo ""

# Get current public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
echo "Current Public IP: $PUBLIC_IP"

# Check current DNS
DNS_IP=$(nslookup wg.buq.duckdns.org 2>/dev/null | grep "Address:" | tail -1 | awk '{print $2}')
echo "Current DNS IP: $DNS_IP"

if [ "$PUBLIC_IP" != "$DNS_IP" ]; then
    echo ""
    echo "⚠️ DNS IP doesn't match server IP, updating..."
    
    # Update Duck DNS
    RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=$PUBLIC_IP")
    
    if [ "$RESPONSE" = "OK" ]; then
        echo "✅ Duck DNS updated successfully!"
        echo "🕐 Wait 2-3 minutes for DNS propagation"
    else
        echo "❌ Error updating Duck DNS: $RESPONSE"
    fi
else
    echo "✅ DNS is already correct"
fi

echo ""
echo "🔗 Duck DNS Management URL:"
echo "https://www.duckdns.org/domains"
echo ""
echo "📋 Your Duck DNS Info:"
echo "Domain: buq.duckdns.org"
echo "Token: dfe377ca-478f-4f48-9d9d-3abbc069f5c0"
echo "Email: hendrabangundwir@gmail.com"
