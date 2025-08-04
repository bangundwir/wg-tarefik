#!/bin/bash

echo "=== WireGuard Internet Routing Fix ==="
echo ""

# Must run as root for iptables
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    echo "Usage: sudo ./fix-routing.sh"
    exit 1
fi

# Get network interface
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
echo "🌐 Main network interface: $INTERFACE"

# Enable IP forwarding
echo "1. Enabling IP forwarding..."
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p
echo "   ✅ IP forwarding enabled"

# Add iptables rules for WireGuard
echo ""
echo "2. Adding iptables rules for WireGuard..."

# Clear existing rules that might conflict
iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o $INTERFACE -j MASQUERADE 2>/dev/null || true
iptables -D FORWARD -i wg0 -j ACCEPT 2>/dev/null || true
iptables -D FORWARD -o wg0 -j ACCEPT 2>/dev/null || true

# Add new rules
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $INTERFACE -j MASQUERADE
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

# Also add rules for established connections
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "   ✅ iptables rules added"

# Save iptables rules
echo ""
echo "3. Saving iptables rules..."
if command -v netfilter-persistent > /dev/null; then
    netfilter-persistent save
    echo "   ✅ Rules saved with netfilter-persistent"
elif command -v iptables-save > /dev/null; then
    iptables-save > /etc/iptables/rules.v4
    echo "   ✅ Rules saved to /etc/iptables/rules.v4"
else
    echo "   ⚠️  Could not save rules permanently"
    echo "   💡 Install iptables-persistent: apt install iptables-persistent"
fi

# Configure UFW if present
if command -v ufw > /dev/null; then
    echo ""
    echo "4. Configuring UFW firewall..."
    ufw allow 51820/udp comment 'WireGuard'
    ufw allow OpenSSH
    echo "   ✅ UFW configured for WireGuard"
fi

# Restart WG-Easy container to apply changes
echo ""
echo "5. Restarting WG-Easy container..."
docker restart wg-easy
sleep 5
echo "   ✅ WG-Easy restarted"

echo ""
echo "=== Fix Complete! ==="
echo ""
echo "🎉 WireGuard internet routing should now work!"
echo ""
echo "📋 What was fixed:"
echo "   ✅ IP forwarding enabled"
echo "   ✅ NAT/Masquerade rule added"
echo "   ✅ Forward rules added"
echo "   ✅ Firewall configured"
echo "   ✅ WG-Easy restarted"
echo ""
echo "🔄 Next steps:"
echo "1. Reconnect your WireGuard client"
echo "2. Test internet: ping 8.8.8.8"
echo "3. Test DNS: nslookup google.com"
echo "4. Check your IP: curl https://httpbin.org/ip"
echo ""
echo "📞 If still not working:"
echo "   - Check client config has AllowedIPs = 0.0.0.0/0"
echo "   - Verify Endpoint is your server's public IP"
echo "   - Check logs: docker logs wg-easy"
