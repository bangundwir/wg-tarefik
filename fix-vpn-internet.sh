#!/bin/bash

echo "=== WireGuard VPN Internet Connection Fix ==="
echo ""

# Check if WG-Easy is running
if ! docker ps | grep -q "wg-easy"; then
    echo "❌ WG-Easy container is not running!"
    echo "Run: ./manage-services.sh wg-start"
    exit 1
fi

echo "✅ WG-Easy container is running"
echo ""

# Get server info
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo "Unknown")
echo "🌐 Server Public IP: $PUBLIC_IP"
echo ""

# Check system requirements
echo "🔍 Checking system requirements..."

# Check if IP forwarding is enabled
IP_FORWARD=$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo "0")
if [ "$IP_FORWARD" = "1" ]; then
    echo "   ✅ IP forwarding is enabled"
else
    echo "   ❌ IP forwarding is disabled - FIXING..."
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf > /dev/null
    sudo sysctl -p > /dev/null 2>&1
    echo "   ✅ IP forwarding enabled"
fi

# Check iptables rules
echo ""
echo "🔍 Checking firewall rules..."

# Get the main network interface
MAIN_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
echo "   Main network interface: $MAIN_INTERFACE"

# Check if masquerade rule exists
if ! sudo iptables -t nat -L POSTROUTING | grep -q "MASQUERADE"; then
    echo "   ❌ NAT/Masquerade rule missing - ADDING..."
    sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $MAIN_INTERFACE -j MASQUERADE
    echo "   ✅ NAT rule added"
else
    echo "   ✅ NAT/Masquerade rule exists"
fi

# Check if forward rules exist
if ! sudo iptables -L FORWARD | grep -q "ACCEPT.*wg0"; then
    echo "   ❌ Forward rules missing - ADDING..."
    sudo iptables -A FORWARD -i wg0 -j ACCEPT
    sudo iptables -A FORWARD -o wg0 -j ACCEPT
    echo "   ✅ Forward rules added"
else
    echo "   ✅ Forward rules exist"
fi

# Make iptables rules persistent
echo ""
echo "🔍 Making firewall rules persistent..."
if command -v iptables-persistent > /dev/null; then
    sudo netfilter-persistent save
    echo "   ✅ Rules saved with netfilter-persistent"
elif command -v iptables-save > /dev/null; then
    sudo iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
    echo "   ✅ Rules saved with iptables-save"
fi

# Check WireGuard interface
echo ""
echo "🔍 Checking WireGuard interface..."
if docker exec wg-easy wg show 2>/dev/null | grep -q "interface: wg0"; then
    echo "   ✅ WireGuard interface is active"
    docker exec wg-easy wg show 2>/dev/null | head -10
else
    echo "   ⚠️  WireGuard interface status unclear"
fi

# Check container networking
echo ""
echo "🔍 Checking container network configuration..."
WG_CONTAINER_IP=$(docker inspect wg-easy | grep "IPAddress" | tail -1 | cut -d'"' -f4)
echo "   WG-Easy container IP: $WG_CONTAINER_IP"

# Test internet connectivity from container
echo ""
echo "🔍 Testing internet connectivity from WG-Easy container..."
if docker exec wg-easy ping -c 2 8.8.8.8 > /dev/null 2>&1; then
    echo "   ✅ Container can reach internet"
else
    echo "   ❌ Container cannot reach internet"
fi

# Check common issues
echo ""
echo "🔍 Checking common VPN issues..."

# Check if UFW is blocking
if command -v ufw > /dev/null && sudo ufw status | grep -q "Status: active"; then
    echo "   ⚠️  UFW firewall is active - may need configuration"
    echo "   💡 Run these commands to allow WireGuard:"
    echo "      sudo ufw allow 51820/udp"
    echo "      sudo ufw allow OpenSSH"
fi

# Check if fail2ban is blocking
if command -v fail2ban-client > /dev/null; then
    echo "   ℹ️  Fail2ban detected - ensure it's not blocking VPN traffic"
fi

echo ""
echo "=== Server Configuration Summary ==="
echo "🌐 Public IP: $PUBLIC_IP"
echo "🔌 WireGuard Port: 51820"
echo "🖥️  Interface: $MAIN_INTERFACE"
echo "📋 VPN Network: 10.8.0.0/24"
echo ""

echo "=== Client Configuration Check ==="
echo "📱 Make sure your WireGuard client config has:"
echo "   Endpoint: $PUBLIC_IP:51820"
echo "   AllowedIPs: 0.0.0.0/0 (for full VPN)"
echo "   DNS: 1.1.1.1, 8.8.8.8"
echo ""

echo "=== Manual Fix Commands (if needed) ==="
echo "# Enable IP forwarding permanently:"
echo "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf"
echo "sudo sysctl -p"
echo ""
echo "# Add NAT rules:"
echo "sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $MAIN_INTERFACE -j MASQUERADE"
echo "sudo iptables -A FORWARD -i wg0 -j ACCEPT"
echo "sudo iptables -A FORWARD -o wg0 -j ACCEPT"
echo ""
echo "# Save rules (Ubuntu/Debian):"
echo "sudo apt install iptables-persistent -y"
echo "sudo netfilter-persistent save"
echo ""

echo "=== Testing Commands ==="
echo "# Test from client after connecting:"
echo "ping 8.8.8.8                    # Test basic connectivity"
echo "nslookup google.com             # Test DNS resolution"
echo "curl https://httpbin.org/ip     # Check your external IP"
echo ""

echo "🚀 After running this script, restart WireGuard on your client device!"
echo "📞 If still having issues, check the WG-Easy logs: docker logs wg-easy"
