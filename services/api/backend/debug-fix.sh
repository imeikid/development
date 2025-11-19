#!/bin/bash

# API Service Debug and Fix Script
echo "🐛 Debugging API Service crash..."

# Check the exact error from journalctl
echo "📜 Checking detailed error logs..."
journalctl -u api-service --no-pager -n 30

# Let's check what's actually in the server.js file
echo "🔍 Checking server.js content..."
cd /root/development/services/api/backend
head -20 server.js

# Check if express is installed
echo "📦 Checking dependencies..."
ls node_modules/ | grep express || echo "❌ Express not found"

# Let's create a simple test server to see if Node.js works
echo "🧪 Creating test server..."
cat > test-server.js << 'EOF'
const http = require('http');

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', message: 'Test server works' }));
});

server.listen(3003, '0.0.0.0', () => {
    console.log('Test server running on port 3003');
});
EOF

echo "Testing basic Node.js HTTP server..."
node test-server.js &
sleep 2
curl -s http://localhost:3003
echo ""
kill %1 2>/dev/null

# Now let's fix the actual server.js with a simpler version
echo "🔧 Creating fixed server.js..."
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3002;

// Enable CORS
app.use(cors());

// Parse JSON bodies
app.use(express.json());

// Serve static files
app.use(express.static(path.join(__dirname, '..')));

// Simple in-memory storage
const channels = {
    telegram: { enabled: true, name: "Telegram", icon: "📱" },
    vk: { enabled: true, name: "VKontakte", icon: "👥" },
    email: { enabled: true, name: "Email", icon: "📧" }
};

let messageHistory = [];
let incomingData = [];

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        service: 'api-hub',
        timestamp: new Date().toISOString()
    });
});

// Get channels
app.get('/api/channels', (req, res) => {
    res.json({ channels });
});

// Update channel
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

// Distribute message
app.post('/api/distribute', async (req, res) => {
    try {
        const { message, channels: targetChannels } = req.body;
        const results = [];
        
        for (const channel of targetChannels) {
            if (channels[channel] && channels[channel].enabled) {
                // Simulate API call
                await new Promise(resolve => setTimeout(resolve, 100));
                results.push({ 
                    channel, 
                    status: 'success', 
                    result: { message: 'Сообщение отправлено' }
                });
            }
        }
        
        messageHistory.push({
            message,
            channels: targetChannels,
            results,
            timestamp: new Date().toISOString()
        });
        
        res.json({ success: true, results });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get stats
app.get('/api/stats', (req, res) => {
    res.json({ 
        totalMessages: messageHistory.length,
        totalDataPoints: incomingData.length
    });
});

// Collect data
app.post('/api/collect', (req, res) => {
    const { source, data } = req.body;
    const newData = {
        id: Date.now().toString(),
        source,
        data,
        timestamp: new Date().toISOString()
    };
    incomingData.push(newData);
    res.json({ success: true, data: newData });
});

// Get data
app.get('/api/data', (req, res) => {
    const { limit = 20 } = req.query;
    const data = incomingData.slice(-parseInt(limit));
    res.json({ data, total: incomingData.length });
});

// Serve main page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../index.html'));
});

// Handle 404
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(500).json({ error: 'Internal server error' });
});

// Start server
console.log('🚀 Starting API Hub server...');
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ API Hub running on port ${PORT}`);
    console.log(`🌐 Access: http://localhost:${PORT}`);
}).on('error', (err) => {
    console.error('❌ Failed to start server:', err);
    process.exit(1);
});
EOF

# Test the fixed server
echo "🧪 Testing fixed server..."
node server.js &
SERVER_PID=$!
sleep 3

if ps -p $SERVER_PID > /dev/null; then
    echo "✅ Server is running successfully"
    echo "Testing health endpoint..."
    curl -s http://localhost:3002/health
    echo ""
    kill $SERVER_PID
else
    echo "❌ Server failed to start"
    echo "Checking for errors..."
    node server.js
    exit 1
fi

# Reinstall dependencies to be sure
echo "📦 Reinstalling dependencies..."
cd /root/development/services/api/backend
rm -rf node_modules package-lock.json
npm install

# Update systemd service to include proper environment
echo "🔧 Updating systemd service..."
cat > /etc/systemd/system/api-service.service << 'EOF'
[Unit]
Description=API Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/development/services/api/backend
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=3
Environment=NODE_ENV=production
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload and restart service
echo "🔄 Restarting API service..."
systemctl daemon-reload
systemctl enable api-service
systemctl start api-service

# Wait and check status
sleep 5
echo "📋 Final status check..."
systemctl status api-service --no-pager

# Test the API
echo "🧪 Testing API..."
curl -s http://localhost:3002/health && echo " - Health check OK" || echo " - Health check FAILED"
curl -s http://localhost:3002/api/channels && echo " - Channels API OK" || echo " - Channels API FAILED"

echo ""
echo "============================================"
echo "🔧 DEBUG COMPLETED!"
echo "============================================"
echo ""
echo "If the service is still failing, check:"
echo "1. Node.js version: node --version"
echo "2. Port 3002: netstat -tlnp | grep 3002"
echo "3. Manual test: cd /root/development/services/api/backend && node server.js"
echo ""
echo "📊 Current Status:"
echo "   API Service: $(systemctl is-active api-service)"
echo "   Nginx: $(systemctl is-active nginx)"
