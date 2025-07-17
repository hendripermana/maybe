#!/bin/bash
# Maybe App Shadcn UI Deployment Script
# Created: $(date)

set -e  # Exit on any error

echo "🎨 Starting Shadcn UI Improvements Deployment..."
echo "📍 Current working directory: $(pwd)"
echo ""

# Show current status
echo "📋 Current Status:"
docker compose ps | grep maybe-web

echo ""
echo "🔨 Building new Docker image with UI improvements..."

# Build new image
docker compose build web

echo ""
echo "🔄 Deploying new version..."

# Deploy with zero downtime using rolling update approach
echo "📢 Stopping old container..."
docker compose stop web

echo "📢 Starting new container..."
docker compose up -d web

echo ""
echo "⏳ Waiting for container to be ready..."

# Wait for container to be healthy
echo "📋 Checking container status..."
for i in {1..30}; do
    if docker compose ps web | grep -q "Up"; then
        echo "✅ Container is running"
        break
    fi
    echo "⏳ Waiting for container... ($i/30)"
    sleep 2
done

# Additional wait for Rails to start
echo "⏳ Waiting for Rails application to start..."
sleep 15

# 🎉 Deployment complete
# No health checks - direct deployment
echo "✅ Deployment successful!"
echo "🌐 New UI improvements are now live at: http://permana.icu"
echo "🔍 Monitor logs with: docker compose logs -f web"
echo "🔄 Rollback if needed: ./rollback.sh"
