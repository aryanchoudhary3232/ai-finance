#!/bin/bash
# ==============================================================================
# Production Deployment Script for AI Finance Platform
# Handles Git updates, Prisma migrations, Docker build & restart, and healthcheck
# ==============================================================================

set -euo pipefail

echo "========================================================"
echo "Starting AI Finance Platform Production Deployment"
echo "========================================================"

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$APP_DIR"

# 1. Environment Verification
if [ ! -f .env ]; then
  echo "Error: .env file not found in $APP_DIR!"
  echo "Please copy .env.example to .env and fill in production secrets."
  exit 1
fi

# 2. Pull Latest Git Changes
echo "[1/5] Pulling latest code changes..."
git pull origin main

# 3. Apply Prisma Database Migrations
echo "[2/5] Running Prisma database migrations..."
if command -v npx &> /dev/null; then
  npx --yes prisma@6.0.1 migrate deploy
else
  # If running exclusively inside Docker
  docker compose run --rm web npx --yes prisma@6.0.1 migrate deploy
fi

# 4. Build and Restart Docker Containers
echo "[3/5] Building and restarting Docker containers..."
docker compose up -d --build --remove-orphans

# 5. Health Check
echo "[4/5] Verifying application health..."
HEALTH_URL="http://127.0.0.1:3000"
MAX_RETRIES=15
COUNT=0

until curl -s -f "$HEALTH_URL" > /dev/null || [ $COUNT -ge $MAX_RETRIES ]; do
  echo "Waiting for web container to become ready... ($((COUNT+1))/$MAX_RETRIES)"
  sleep 3
  COUNT=$((COUNT+1))
done

if [ $COUNT -ge $MAX_RETRIES ]; then
  echo "Deployment Warning: Application did not respond within expected time."
  echo "Check container logs using: docker compose logs -n 50 web"
  exit 1
fi

# 6. Cleanup Unused Docker Resources
echo "[5/5] Cleaning up unused Docker images..."
docker image prune -f

echo "========================================================"
echo "AI Finance Platform deployed and running successfully!"
echo "Status:"
docker compose ps
echo "========================================================"
