# WireGuard Easy with Traefik Setup

This setup configures WireGuard Easy with Traefik reverse proxy using your Duck DNS domain `buq.duckdns.org`.

## Quick Start

### Windows
1. Run the setup script:
   ```cmd
   setup.bat
   ```

### Linux/macOS
1. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```

2. Install Traefik first:
   ```bash
   ./install-traefik.sh
   ```

3. Wait 2-3 minutes, then install WG-Easy:
   ```bash
   ./install-wg-easy.sh
   ```

**Or install using official directory structure:**
```bash
chmod +x setup-official.sh manage-official.sh
./setup-official.sh
```

**Or install both at once (current method):**
```bash
./manage-services.sh install-all
```

2. Access your services:
   - **WireGuard Easy**: https://wg.buq.duckdns.org
   - **Traefik Dashboard**: https://traefik.buq.duckdns.org

## Configuration Details

### Duck DNS Configuration
- **Domain**: buq.duckdns.org
- **Email**: hendrabangundwir@gmail.com
- **Token**: dfe377ca-478f-4f48-9d9d-3abbc069f5c0

### WireGuard Easy Settings (v15 Changes)
- **Host**: Configured through Web UI Admin Panel
- **Password**: Set through Web UI setup wizard
- **Port**: 51820 (UDP) for VPN, 51821 (TCP) for Web Interface
- **Web Interface**: https://wg.buq.duckdns.org
- **Configuration**: Most settings now configured through Web UI instead of environment variables

**Important Note for v15**: WG-Easy v15 is a complete rewrite. Most configuration that was previously done through environment variables is now done through the Web UI Admin Panel.

### Traefik Dashboard
- **URL**: https://traefik.buq.duckdns.org
- **Username**: admin
- **Password**: Arema123

## Manual Setup Steps

If you prefer to set up manually:

1. Create Docker network:
   ```cmd
   docker network create traefik
   ```

2. Set permissions for SSL certificates:
   ```cmd
   icacls traefik\acme.json /inheritance:r /grant:r "%USERNAME%:(F)"
   ```

3. Start services:
   ```cmd
   docker-compose up -d
   ```

## DNS Configuration

Make sure to point these subdomains to your server's public IP:
- `wg.buq.duckdns.org`
- `traefik.buq.duckdns.org`

You can update your Duck DNS IP using:
```
https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=YOUR_PUBLIC_IP
```

## Firewall Requirements

Ensure these ports are open:
- **80** (HTTP - redirects to HTTPS)
- **443** (HTTPS - Traefik/Web Interface)
- **51820** (UDP - WireGuard VPN)

## File Structure

### Current Method (Flexible)
```
├── traefik-compose.yml         # Traefik Docker Compose
├── wg-easy-compose.yml         # WG-Easy Docker Compose
├── docker-compose.yml          # Combined (legacy)
├── install-traefik.sh          # Install Traefik first
├── install-wg-easy.sh          # Install WG-Easy after Traefik
├── manage-services.sh          # Complete service management
```

### Official Method (Following WG-Easy docs)
```
/etc/docker/containers/traefik/docker-compose.yml
/etc/docker/containers/wg-easy/docker-compose.yml
/etc/docker/volumes/traefik/traefik.yml
/etc/docker/volumes/traefik/traefik_dynamic.yml
/etc/docker/volumes/traefik/acme.json
```

### Support Files
```
├── setup-official.sh           # Official directory setup
├── manage-official.sh          # Official directory management
├── setup.bat                   # Windows setup script
├── setup.sh                    # Linux/macOS setup script (legacy)
├── debug.sh                    # Troubleshooting script
├── fix-vpn-internet.sh         # Fix VPN internet issues
├── fix-routing.sh              # Fix server routing
├── client-config-help.sh       # Client configuration help
└── traefik/                    # Traefik configuration files
```

## Service Management

### Current Method (Flexible Structure)
Use the unified management script:

```bash
# Installation (step by step)
./manage-services.sh install-traefik    # Install Traefik first
./manage-services.sh install-wg         # Install WG-Easy after Traefik
./manage-services.sh install-all        # Install both services

# Service control
./manage-services.sh start              # Start all services
./manage-services.sh stop               # Stop all services  
./manage-services.sh restart            # Restart all services
./manage-services.sh status             # Show service status

# Individual service control
./manage-services.sh traefik-start      # Start only Traefik
./manage-services.sh wg-start           # Start only WG-Easy
./manage-services.sh traefik-logs       # View Traefik logs
./manage-services.sh wg-logs            # View WG-Easy logs

# Utilities
./manage-services.sh update-dns         # Update Duck DNS IP
./manage-services.sh debug              # Run troubleshooting
./manage-services.sh fix-vpn            # Fix VPN internet issues
./manage-services.sh client-help        # Client configuration help
./manage-services.sh cleanup            # Clean up everything
./manage-services.sh help               # Show all commands
```

### Official Method (Following WG-Easy Documentation)
Use the official management script:

```bash
# Setup using official directory structure
./manage-official.sh setup-official

# Service control
./manage-official.sh start-all          # Start all services
./manage-official.sh stop-all           # Stop all services
./manage-official.sh restart-all        # Restart all services
./manage-official.sh status-all         # Show service status

# Individual service control
./manage-official.sh traefik-start      # Start only Traefik
./manage-official.sh wg-start           # Start only WG-Easy
./manage-official.sh traefik-logs       # View Traefik logs
./manage-official.sh wg-logs            # View WG-Easy logs

# Utilities
./manage-official.sh update-all         # Update both services
./manage-official.sh cleanup-official   # Clean up official installation
```

## Auto Duck DNS Update

To automatically update your Duck DNS IP when it changes:

1. Make the script executable:
   ```bash
   chmod +x update-duckdns.sh
   ```

2. Add to crontab (runs every 5 minutes):
   ```bash
   crontab -e
   # Add this line:
   */5 * * * * /full/path/to/update-duckdns.sh
   ```

## Troubleshooting

- Check service status: `docker-compose ps`
- View logs: `docker-compose logs -f`
- Restart services: `docker-compose restart`
- Stop services: `docker-compose down`
