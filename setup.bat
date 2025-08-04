@echo off
echo Setting up WireGuard Easy with Traefik...

REM Create Docker network
echo Creating Docker network...
docker network create traefik 2>nul

REM Set proper permissions for acme.json (Windows equivalent)
echo Setting permissions for acme.json...
icacls traefik\acme.json /inheritance:r /grant:r "%USERNAME%:(F)"

REM Create wg-easy data directory
if not exist "wg-easy" mkdir wg-easy

echo Starting services...
docker-compose up -d

echo.
echo Setup complete!
echo.
echo Services:
echo - WireGuard Easy: https://wg.buq.duckdns.org
echo - Traefik Dashboard: https://traefik.buq.duckdns.org (admin:Arema123)
echo.
echo Make sure to:
echo 1. Point wg.buq.duckdns.org and traefik.buq.duckdns.org to your server IP
echo 2. Ensure ports 80, 443, and 51820 are open in your firewall
echo 3. Update Duck DNS with your current IP address using token: dfe377ca-478f-4f48-9d9d-3abbc069f5c0
echo.
pause
