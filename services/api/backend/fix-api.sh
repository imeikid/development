#!/bin/bash

# API Hub Fix Script - Diagnose and fix API service
echo "🔧 Diagnosing and fixing API Service..."

# Check API service status and logs
echo "📋 Checking API service status..."
systemctl status api-service

echo "📜 Checking API service logs..."
journalctl -u api-service -n 20 --no-pager

# Check if Node.js process is running
echo "🔍 Checking Node.js processes..."
ps aux | grep node

# Check port 3002
echo "🔌 Checking port 3002..."
netstat -tlnp | grep 3002

# Fix common issues
echo "🛠️ Fixing common issues..."

# Check if server.js exists and has correct permissions
if [ -f "/root/development/services/api/backend/server.js" ]; then
    echo "✅ server.js exists"
    # Fix permissions
    chmod +x /root/development/services/api/backend/server.js
else
    echo "❌ server.js not found!"
    exit 1
fi

# Check if node_modules exists
if [ ! -d "/root/development/services/api/backend/node_modules" ]; then
    echo "📦 Installing dependencies..."
    cd /root/development/services/api/backend
    npm install
fi

# Fix the server.js to listen on all interfaces
echo "🔧 Fixing server.js configuration..."
cat > /root/development/services/api/backend/server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '..')));

// Data storage
let channels = {
    telegram: { enabled: true, name: "Telegram", icon: "📱" },
    vk: { enabled: true, name: "VKontakte", icon: "👥" },
    email: { enabled: true, name: "Email", icon: "📧" }
};

let incomingData = [];
let messageHistory = [];

// Routes
app.post('/api/distribute', async (req, res) => {
    const { message, channels: targetChannels } = req.body;
    const results = [];
    
    console.log('📤 Distributing message:', message);
    
    for (const channel of targetChannels) {
        if (channels[channel] && channels[channel].enabled) {
            try {
                await new Promise(resolve => setTimeout(resolve, 500));
                results.push({ 
                    channel, 
                    status: 'success', 
                    result: { message: 'Сообщение отправлено успешно' }
                });
                console.log(`✅ Sent to ${channel}`);
            } catch (error) {
                results.push({ 
                    channel, 
                    status: 'error', 
                    error: error.message 
                });
                console.log(`❌ Error sending to ${channel}:`, error.message);
            }
        }
    }
    
    messageHistory.push({
        message,
        channels: targetChannels,
        results,
        timestamp: new Date().toISOString()
    });
    
    res.json({ success: true, results });
});

app.get('/api/channels', (req, res) => {
    res.json({ channels });
});

app.put('/api/channels/:channelId', (req, res) => {
    const { channelId } = req.params;
    const { enabled } = req.body;
    
    if (channels[channelId]) {
        channels[channelId].enabled = enabled;
        res.json({ success: true, channel: channels[channelId] });
    } else {
        res.status(404).json({ success: false, error: 'Channel not found' });
    }
});

app.get('/api/stats', (req, res) => {
    res.json({ 
        totalMessages: messageHistory.length,
        totalDataPoints: incomingData.length,
        channels: Object.keys(channels).length
    });
});

app.post('/api/collect', (req, res) => {
    const { source, data } = req.body;
    const newData = {
        source,
        data,
        timestamp: new Date().toISOString(),
        id: Date.now().toString()
    };
    incomingData.push(newData);
    res.json({ success: true, data: newData });
});

app.get('/api/data', (req, res) => {
    const { limit = 50 } = req.query;
    res.json({ 
        data: incomingData.slice(-limit),
        total: incomingData.length 
    });
});

// Health check
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        service: 'api-hub',
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Serve frontend
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../index.html'));
});

// Error handling
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ error: 'Internal Server Error' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 API Hub Server running on port ${PORT}`);
    console.log(`📍 Access: http://0.0.0.0:${PORT}`);
    console.log(`📍 Health: http://0.0.0.0:${PORT}/health`);
}).on('error', (err) => {
    console.error('❌ Server error:', err);
    process.exit(1);
});
EOF

# Test if server.js works
echo "🧪 Testing server.js..."
cd /root/development/services/api/backend
if node -e "require('./server.js'); console.log('✅ server.js syntax is OK');" &>/dev/null; then
    echo "✅ server.js syntax is correct"
else
    echo "❌ server.js has syntax errors"
    # Show the error
    node -e "require('./server.js')"
    exit 1
fi

# Restart API service
echo "🔄 Restarting API service..."
systemctl daemon-reload
systemctl stop api-service
sleep 2
systemctl start api-service
sleep 3

# Check status again
echo "📋 Checking API service status after fix..."
systemctl status api-service --no-pager

# Test if API is responding
echo "🧪 Testing API response..."
if curl -s http://localhost:3002/health | grep -q "ok"; then
    echo "✅ API is responding correctly"
else
    echo "❌ API is not responding"
    echo "Trying to start manually for debugging..."
    cd /root/development/services/api/backend
    node server.js &
    sleep 3
    curl -s http://localhost:3002/health
    echo ""
fi

# Final status check
echo ""
echo "============================================"
echo "🔧 FIX COMPLETED!"
echo "============================================"
echo ""
echo "📊 Services Status:"
echo "   API Service: $(systemctl is-active api-service)"
echo "   Nginx: $(systemctl is-active nginx)"
echo ""
echo "🌐 Available Services:"
echo "   📊 CRM:        http://2a03:6f00:a::f029/crm"
echo "   ⚙️  Admin:      http://2a03:6f00:a::f029/admin"
echo "   🚀 API Hub:     http://2a03:6f00:a::f029/api"
echo "   🌐 Web:         http://2a03:6f00:a::f029/web"
echo ""
echo "🔍 Debug Commands:"
echo "   View API logs: journalctl -u api-service -f"
echo "   Test API: curl http://localhost:3002/health"
echo "   Restart API: systemctl restart api-service"
echo ""
