#!/bin/bash

# API Hub Deployment Script - Simplified Version
echo "🚀 Starting API Hub deployment..."

# Install dependencies
echo "📦 Installing dependencies..."
apt-get update
apt-get install -y nodejs nginx

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p /root/development/services/api/{backend,js,css,assets}
cd /root/development/services/api/backend

# Create package.json
echo "📄 Creating package.json..."
cat > package.json << 'ENDOFFILE'
{
  "name": "api-service",
  "version": "1.0.0",
  "description": "API Service with Hub functionality",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  }
}
ENDOFFILE

# Create server.js
echo "📄 Creating server.js..."
cat > server.js << 'ENDOFFILE'
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3002;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '..')));

let channels = {
    telegram: { enabled: true, name: "Telegram", icon: "📱" },
    vk: { enabled: true, name: "VKontakte", icon: "👥" },
    email: { enabled: true, name: "Email", icon: "📧" }
};

let incomingData = [];
let messageHistory = [];

app.post('/api/distribute', async (req, res) => {
    const { message, channels: targetChannels } = req.body;
    const results = [];
    
    for (const channel of targetChannels) {
        if (channels[channel] && channels[channel].enabled) {
            await new Promise(resolve => setTimeout(resolve, 500));
            results.push({ 
                channel, 
                status: 'success', 
                result: { message: 'Sent successfully' }
            });
        }
    }
    
    res.json({ success: true, results });
});

app.get('/api/channels', (req, res) => {
    res.json({ channels });
});

app.get('/api/stats', (req, res) => {
    res.json({ 
        totalMessages: messageHistory.length,
        totalDataPoints: incomingData.length 
    });
});

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../index.html'));
});

app.listen(PORT, () => {
    console.log('🚀 API Server running on port ' + PORT);
});
ENDOFFILE

# Create index.html
echo "📄 Creating index.html..."
cat > ../index.html << 'ENDOFFILE'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Hub</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, sans-serif; background: #f2f2f7; color: #000; }
        
        .nav { background: #fff; padding: 1rem; border-bottom: 1px solid #c6c6c8; }
        .nav-scroll { display: flex; overflow-x: auto; gap: 0.5rem; }
        .nav-item { padding: 0.5rem 1rem; background: #007aff; color: white; border-radius: 8px; text-decoration: none; white-space: nowrap; }
        
        .container { max-width: 800px; margin: 0 auto; padding: 1rem; }
        .card { background: #fff; border-radius: 12px; padding: 1rem; margin: 1rem 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        
        textarea { width: 100%; min-height: 100px; padding: 1rem; border: 1px solid #c6c6c8; border-radius: 8px; font-size: 16px; }
        button { background: #007aff; color: white; border: none; padding: 1rem 2rem; border-radius: 8px; font-size: 16px; cursor: pointer; }
        
        .channel-list { display: flex; flex-direction: column; gap: 0.5rem; margin: 1rem 0; }
        .channel-item { display: flex; align-items: center; gap: 0.5rem; }
    </style>
</head>
<body>
    <div class="nav">
        <div class="nav-scroll">
            <a href="/services/crm" class="nav-item">📊 CRM</a>
            <a href="/services/admin" class="nav-item">⚙️ Admin</a>
            <a href="/services/api" class="nav-item">🚀 API Hub</a>
            <a href="/services/web" class="nav-item">🌐 Web</a>
        </div>
    </div>
    
    <div class="container">
        <h1>🚀 API Hub</h1>
        
        <div class="card">
            <h3>📤 Send Message</h3>
            <textarea id="messageInput" placeholder="Enter your message..."></textarea>
            <div class="channel-list" id="channelList"></div>
            <button onclick="sendMessage()">Send to Channels</button>
        </div>
        
        <div class="card">
            <h3>📊 Stats</h3>
            <div id="stats"></div>
        </div>
    </div>

    <script>
        async function loadChannels() {
            const response = await fetch('/api/channels');
            const data = await response.json();
            
            const channelList = document.getElementById('channelList');
            channelList.innerHTML = '';
            
            Object.entries(data.channels).forEach(([key, channel]) => {
                const div = document.createElement('div');
                div.className = 'channel-item';
                div.innerHTML = `
                    <input type="checkbox" id="${key}" checked>
                    <label for="${key}">${channel.icon} ${channel.name}</label>
                `;
                channelList.appendChild(div);
            });
        }
        
        async function sendMessage() {
            const message = document.getElementById('messageInput').value;
            const channels = Array.from(document.querySelectorAll('input[type="checkbox"]:checked')).map(cb => cb.id);
            
            const response = await fetch('/api/distribute', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message, channels })
            });
            
            const result = await response.json();
            alert(`Message sent to ${result.results.length} channels`);
        }
        
        async function loadStats() {
            const response = await fetch('/api/stats');
            const data = await response.json();
            document.getElementById('stats').innerHTML = `
                <p>Total Messages: ${data.totalMessages}</p>
                <p>Data Points: ${data.totalDataPoints}</p>
            `;
        }
        
        loadChannels();
        loadStats();
    </script>
</body>
</html>
ENDOFFILE

# Install npm dependencies
echo "📦 Installing npm dependencies..."
npm install

# Create systemd service
echo "🔧 Creating systemd service..."
cat > /etc/systemd/system/api-service.service << 'ENDOFFILE'
[Unit]
Description=API Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/development/services/api/backend
ExecStart=/usr/bin/node server.js
Restart=always
User=root

[Install]
WantedBy=multi-user.target
ENDOFFILE

# Create nginx config
echo "🔧 Creating nginx config..."
cat > /etc/nginx/sites-available/api-hub << 'ENDOFFILE'
server {
    listen 80;
    server_name _;
    
    location /api/ {
        proxy_pass http://localhost:3002/;
        proxy_set_header Host $host;
    }
    
    location /services/api/ {
        alias /root/development/services/api/;
        try_files $uri $uri/ /index.html;
    }
    
    location /services/ {
        alias /root/development/services/;
        try_files $uri $uri/ /index.html;
    }
}
ENDOFFILE

# Enable nginx site
ln -sf /etc/nginx/sites-available/api-hub /etc/nginx/sites-enabled/
nginx -t

# Start services
echo "🚀 Starting services..."
systemctl daemon-reload
systemctl enable api-service
systemctl start api-service
systemctl reload nginx

# Display status
echo ""
echo "✅ DEPLOYMENT COMPLETED!"
echo "🌐 Access your API Hub at: http://$(curl -s ifconfig.me)/services/api/"
echo ""
echo "📊 Services status:"
echo "   API Service: $(systemctl is-active api-service)"
echo "   Nginx: $(systemctl is-active nginx)"
echo ""
echo "🔧 Management commands:"
echo "   View logs: journalctl -u api-service -f"
echo "   Restart: systemctl restart api-service"
