#!/bin/bash
# ==============================================================================
# Automated SSL Setup Script for aifinance.iiitstudent.me
# ==============================================================================

set -euo pipefail

DOMAIN="aifinance.iiitstudent.me"
EMAIL="aryanchoudhary3232@gmail.com"
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$APP_DIR"

echo "========================================================"
echo "Starting Let's Encrypt SSL Setup for $DOMAIN"
echo "========================================================"

# 1. Install Certbot if not present
if ! command -v certbot &> /dev/null; then
  echo "Installing certbot..."
  sudo apt-get update -y
  sudo apt-get install -y certbot
fi

# 2. Stop Docker Nginx temporarily to release port 80 for verification
echo "Stopping Nginx container for port 80 verification..."
docker compose stop nginx

# 3. Obtain SSL Certificate
echo "Obtaining SSL certificate from Let's Encrypt..."
sudo certbot certonly --standalone -d "$DOMAIN" --agree-tos --non-interactive -m "$EMAIL" --expand

# 4. Activate HTTPS Nginx configuration
echo "Activating HTTPS in Nginx configuration..."
cat << 'EOF' > nginx/conf.d/default.conf
upstream nextjs_upstream {
    server web:3000;
    keepalive 64;
}

# HTTP Server - Redirect everything to HTTPS
server {
    listen 80;
    server_name aifinance.iiitstudent.me localhost _;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS Server - Production SSL Reverse Proxy
server {
    listen 443 ssl;
    server_name aifinance.iiitstudent.me;

    ssl_certificate /etc/letsencrypt/live/aifinance.iiitstudent.me/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/aifinance.iiitstudent.me/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    client_max_body_size 10M;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Next.js Static Assets Caching
    location /_next/static/ {
        proxy_pass http://nextjs_upstream;
        proxy_cache_bypass $http_upgrade;
        expires 365d;
        access_log off;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    # Public static files caching
    location ~* ^/(favicon\.ico|logo.*\.png|banner\.jpeg)$ {
        proxy_pass http://nextjs_upstream;
        expires 30d;
        access_log off;
        add_header Cache-Control "public, max-age=2592000";
    }

    # Application & API Routes
    location / {
        proxy_pass http://nextjs_upstream;
        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

# 5. Restart Nginx container
echo "Starting Nginx container with SSL enabled..."
docker compose up -d nginx

echo "========================================================"
echo "SSL Setup Completed Successfully!"
echo "Your platform is live and secured with HTTPS at:"
echo "https://$DOMAIN"
echo "========================================================"
