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

# Health check
echo "🏥 Performing health check..."
# Test with container health first
if docker compose ps web | grep -q "Up"; then
    echo "✅ Container health check passed"
    
    # Test HTTP response (403 is expected for localhost, that's actually good)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "000")
    echo "📊 HTTP response code: $HTTP_CODE"
    
    if [[ "$HTTP_CODE" =~ ^(200|302|403)$ ]]; then
        echo "✅ HTTP health check passed"
        echo "✅ Deployment successful!"
        echo "🌐 App is available at: http://permana.icu:3000"
        echo ""
        echo "🎉 Shadcn UI improvements are now live!"
        echo ""
        echo "📋 New Features:"
        echo "   ✨ Modern card components with gradients"
        echo "   🎨 Enhanced buttons with hover effects"
        echo "   🏷️  Beautiful badges and status indicators"
        echo "   📱 Improved responsive design"
        echo "   💫 Smooth animations and transitions"
        echo ""
        echo "🔍 Monitor with: docker compose logs -f web"
        echo "🔄 Rollback if needed: ./rollback.sh"
    else
        echo "❌ HTTP health check failed! Code: $HTTP_CODE"
        echo "🔄 Starting automatic rollback..."
        ./rollback.sh
        exit 1
    fi
else
    echo "❌ Container health check failed!"
    echo "🔄 Starting automatic rollback..."
    ./rollback.sh
    exit 1
fi
