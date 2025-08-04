# WireGuard Easy Troubleshooting Guide

## Masalah Umum dan Solusi

### 1. WG-Easy tidak bisa diakses melalui wg.buq.duckdns.org

**Langkah Troubleshooting:**

```bash
# 1. Make scripts executable
chmod +x fix-wg.sh debug.sh

# 2. Run the fix script
./fix-wg.sh

# 3. If still not working, run debug script
./debug.sh
```

### 2. Cek Manual

**Step by Step:**

1. **Cek apakah container berjalan:**
   ```bash
   docker-compose ps
   ```
   Pastikan kedua container (traefik dan wg-easy) berstatus "Up"

2. **Cek logs WG-Easy:**
   ```bash
   docker logs wg-easy
   ```
   Cari error messages

3. **Cek logs Traefik:**
   ```bash
   docker logs traefik
   ```

4. **Test akses langsung (tanpa Traefik):**
   ```bash
   # Replace YOUR_SERVER_IP with actual server IP
   curl http://YOUR_SERVER_IP:51821
   ```

5. **Cek DNS Duck DNS:**
   ```bash
   nslookup wg.buq.duckdns.org
   ```

### 3. Kemungkinan Masalah:

#### A. DNS/Domain Issues
- **Masalah**: Domain wg.buq.duckdns.org tidak mengarah ke server
- **Solusi**: 
  ```bash
  # Update Duck DNS IP
  curl "https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=$(curl -s http://checkip.amazonaws.com)"
  ```

#### B. Firewall Issues
- **Masalah**: Port 80, 443, 51820, 51821 terblokir
- **Solusi**:
  ```bash
  # Ubuntu/Debian
  sudo ufw allow 80
  sudo ufw allow 443
  sudo ufw allow 51820/udp
  sudo ufw allow 51821/tcp
  
  # CentOS/RHEL
  sudo firewall-cmd --permanent --add-port=80/tcp
  sudo firewall-cmd --permanent --add-port=443/tcp
  sudo firewall-cmd --permanent --add-port=51820/udp
  sudo firewall-cmd --permanent --add-port=51821/tcp
  sudo firewall-cmd --reload
  ```

#### C. SSL Certificate Issues
- **Masalah**: Let's Encrypt tidak bisa generate certificate
- **Solusi**:
  ```bash
  # Remove acme.json and restart
  rm traefik/acme.json
  touch traefik/acme.json
  chmod 600 traefik/acme.json
  docker-compose restart traefik
  ```

#### D. Network Connectivity Issues
- **Masalah**: Container tidak bisa saling komunikasi
- **Solusi**:
  ```bash
  # Recreate networks
  docker-compose down
  docker network rm traefik wg 2>/dev/null || true
  docker network create traefik
  docker-compose up -d
  ```

### 4. Verifikasi Akhir

Setelah menjalankan fix, cek:

1. **Traefik Dashboard**: https://traefik.buq.duckdns.org
   - Login: admin / Arema123
   - Cari service "wg-easy" di dashboard

2. **WG-Easy Interface**: https://wg.buq.duckdns.org
   - Login dengan password: Arema123

3. **Direct Access Test**: http://YOUR_SERVER_IP:51821

### 5. Quick Commands

```bash
# Restart everything
docker-compose restart

# View real-time logs
docker-compose logs -f

# Check service status
docker-compose ps

# Update Duck DNS IP
curl "https://www.duckdns.org/update?domains=buq&token=dfe377ca-478f-4f48-9d9d-3abbc069f5c0&ip=$(curl -s http://checkip.amazonaws.com)"
```

### 6. Common Error Messages dan Solusi

| Error | Solusi |
|-------|--------|
| "network traefik not found" | `docker network create traefik` |
| "port already in use" | `docker-compose down` dan coba lagi |
| "permission denied acme.json" | `chmod 600 traefik/acme.json` |
| "no such host wg-easy" | Pastikan container di network yang sama |
| "certificate error" | Wait 5-10 minutes untuk Let's Encrypt |
