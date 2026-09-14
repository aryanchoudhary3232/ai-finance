#!/bin/bash
# ==============================================================================
# AWS EC2 Linux Server Setup Script for AI Finance Platform
# Supported OS: Ubuntu 22.04 LTS / 24.04 LTS
# ==============================================================================

set -euo pipefail

echo "======================================================"
echo "Starting AWS EC2 Linux Server Initialization..."
echo "======================================================"

# 1. Update and Upgrade System Packages
echo "[1/6] Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release ufw git fail2ban

# 2. Configure UFW Firewall
echo "[2/6] Configuring UFW firewall (SSH, HTTP, HTTPS)..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# 3. Install Docker Engine and Docker Compose
echo "[3/6] Installing Docker and Docker Compose..."
if ! command -v docker &> /dev/null; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Enable and start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker

    # Add current user to docker group
    sudo usermod -aG docker "$USER"
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# 4. Install Node.js and PM2 (For Process Management option)
echo "[4/6] Installing Node.js LTS and PM2..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2
    sudo pm2 startup systemd -u "$USER" --hp "$HOME"
fi

# 5. Create Deployment Directory and Permissions
echo "[5/6] Creating deployment directory..."
DEPLOY_DIR="/var/www/ai-finance"
sudo mkdir -p "$DEPLOY_DIR"
sudo chown -R "$USER":"$USER" "$DEPLOY_DIR"

# 6. Summary
echo "[6/6] Setup completed successfully!"
echo "======================================================"
echo "Next Steps:"
echo "1. Re-login or run 'newgrp docker' to use docker without sudo."
echo "2. Clone your repository into $DEPLOY_DIR"
echo "3. Add your production .env file in $DEPLOY_DIR"
echo "4. Run './scripts/deploy.sh' to launch the platform."
echo "======================================================"
