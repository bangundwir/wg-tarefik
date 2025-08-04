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

**Or install both at once:**
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

### WireGuard Easy Settings
- **Host**: wg.buq.duckdns.org
- **Password**: admin123
- **Port**: 51820 (UDP)
- **Web Interface**: 51821
- **Default VPN Network**: 10.8.0.x

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

```
├── traefik-compose.yml         # Traefik Docker Compose
├── wg-easy-compose.yml         # WG-Easy Docker Compose
├── docker-compose.yml          # Combined (legacy)
├── install-traefik.sh          # Install Traefik first
├── install-wg-easy.sh          # Install WG-Easy after Traefik
├── manage-services.sh          # Complete service management
├── setup.bat                   # Windows setup script
├── setup.sh                    # Linux/macOS setup script (legacy)
├── debug.sh                    # Troubleshooting script
├── traefik/
│   ├── traefik.yml            # Traefik main configuration
│   ├── traefik_dynamic.yml    # Traefik dynamic configuration
│   └── acme.json              # SSL certificates storage
└── wg-easy/                   # WireGuard configuration (created automatically)
```

## Service Management

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
./manage-services.sh cleanup            # Clean up everything
./manage-services.sh help               # Show all commands
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
