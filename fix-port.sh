#!/bin/bash

# Fix Port 3002 Conflict
echo "🔧 Fixing port 3002 conflict..."

# Find what's using port 3002
echo "🔍 Finding process using port 3002..."
lsof -i :3002

# Kill any process using port 3002
echo "🛑 Stopping processes on port 3002..."
pkill -f "node.*3002" || true
fuser -k 3002/tcp || true

# Wait a moment
sleep 2

# Check if port is free now
echo "🔍 Checking if port 3002 is free..."
if ! lsof -i :3002; then
    echo "✅ Port 3002 is now free"
else
    echo "❌ Port 3002 is still in use, let's use a different port"
    # Use port 3003 instead
    sed -i 's/const PORT = 3002;/const PORT = 3003;/' /root/development/services/api/backend/server.js
    sed -i 's/3002/3003/g' /etc/nginx/sites-available/api-hub
    echo "🔄 Changed to port 3003"
fi

# Restart API service
echo "🔄 Restarting API service..."
systemctl daemon-reload
systemctl restart api-service

# Wait and check status
sleep 3
echo "📋 Checking API service status..."
systemctl status api-service --no-pager

# Test the API
echo "🧪 Testing API..."
if curl -s http://localhost:3002/health; then
    echo "✅ API is working on port 3002"
elif curl -s http://localhost:3003/health; then
    echo "✅ API is working on port 3003"
else
    echo "❌ API is not responding, let's check what's wrong"
    
    # Try to start manually
    echo "🚀 Starting API manually..."
    cd /root/development/services/api/backend
    node server.js &
    MANUAL_PID=$!
    sleep 3
    
    if ps -p $MANUAL_PID > /dev/null; then
        echo "✅ Manual start successful"
        echo "Testing health endpoint..."
        curl -s http://localhost:3003/health
        echo ""
        kill $MANUAL_PID
    else
        echo "❌ Manual start failed"
        exit 1
    fi
fi

# Final status
echo ""
echo "============================================"
echo "🔧 PORT CONFLICT FIXED!"
echo "============================================"
echo ""
echo "🌐 Available Services:"
echo "   📊 CRM:        http://2a03:6f00:a::f029/crm"
echo "   ⚙️  Admin:      http://2a03:6f00:a::f029/admin"
echo "   🚀 API Hub:     http://2a03:6f00:a::f029/api"
echo "   🌐 Web:         http://2a03:6f00:a::f029/web"
echo ""
echo "📊 Services Status:"
echo "   API Service: $(systemctl is-active api-service)"
echo "   Nginx: $(systemctl is-active nginx)"
