#!/bin/bash

# Fix API Hub after nginx reconfiguration
echo "🔧 Fixing API Hub configuration..."

# Check if API service is running
echo "🔍 Checking API service..."
systemctl status api-service --no-pager

# Check if API is responding on port 3002
echo "🧪 Testing API on port 3002..."
curl -s http://localhost:3002/ || echo "❌ API not responding on 3002"

# Fix the nginx configuration to properly handle API Hub
echo "🔧 Fixing nginx configuration for API Hub..."
cat > /etc/nginx/sites-available/api-hub << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    
    # API backend - proxy to Node.js
    location /api/ {
        proxy_pass http://127.0.0.1:3002/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Handle API requests
        location /api/distribute {
            proxy_pass http://127.0.0.1:3002/api/distribute;
        }
        
        location /api/channels {
            proxy_pass http://127.0.0.1:3002/api/channels;
        }
        
        location /api/stats {
            proxy_pass http://127.0.0.1:3002/api/stats;
        }
        
        location /api/collect {
            proxy_pass http://127.0.0.1:3002/api/collect;
        }
        
        location /api/data {
            proxy_pass http://127.0.0.1:3002/api/data;
        }
    }
    
    # CRM service
    location /crm {
        alias /root/development/services/crm/;
        index index.html;
        try_files $uri $uri/ /crm/index.html;
    }
    
    # Admin service  
    location /admin {
        alias /root/development/services/admin/;
        index index.html;
        try_files $uri $uri/ /admin/index.html;
    }
    
    # Web service
    location /web {
        alias /root/development/services/web/;
        index index.html;
        try_files $uri $uri/ /web/index.html;
    }
    
    # API Hub frontend - serve the frontend files
    location / {
        alias /root/development/services/api/;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Redirects for clean URLs
    location = /crm {
        return 302 /crm/;
    }
    
    location = /admin {
        return 302 /admin/;
    }
    
    location = /web {
        return 302 /web/;
    }
    
    location = /api {
        return 302 /api/;
    }
}
EOF

# Update the symlink
echo "🔗 Updating nginx symlink..."
ln -sf /etc/nginx/sites-available/api-hub /etc/nginx/sites-enabled/default

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
nginx -t

# Reload nginx
echo "🔄 Reloading nginx..."
systemctl reload nginx

# Wait a moment
sleep 2

# Test all endpoints
echo "🧪 Testing all endpoints..."
echo "Testing API Frontend:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/ && echo " - API Frontend OK" || echo " - API Frontend FAILED"

echo "Testing API Backend:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/api/ && echo " - API Backend OK" || echo " - API Backend FAILED"

echo "Testing API Channels:"
curl -s http://localhost/api/channels | head -1 && echo " - API Channels OK" || echo " - API Channels FAILED"

echo "Testing CRM:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/crm && echo " - CRM OK" || echo " - CRM FAILED"

echo "Testing Admin:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/admin && echo " - Admin OK" || echo " - Admin FAILED"

echo "Testing Web:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/web && echo " - Web OK" || echo " - Web FAILED"

# Check what's actually in the API directory
echo "📁 Checking API directory contents..."
ls -la /root/development/services/api/

# If index.html is missing, recreate it
if [ ! -f "/root/development/services/api/index.html" ]; then
    echo "📝 Recreating API Hub frontend..."
    cat > /root/development/services/api/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Hub - Центр управления каналами</title>
    <style>
        :root {
            --ios-bg: #f2f2f7;
            --ios-card-bg: #ffffff;
            --ios-border: #c6c6c8;
            --ios-primary: #007aff;
            --ios-text: #000000;
        }

        [data-theme="dark"] {
            --ios-bg: #000000;
            --ios-card-bg: #1c1c1e;
            --ios-border: #38383a;
            --ios-primary: #0a84ff;
            --ios-text: #ffffff;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, sans-serif; background: var(--ios-bg); color: var(--ios-text); }
        
        .global-nav-container { 
            width: 100%; 
            background: rgba(248, 248, 248, 0.95);
            border-bottom: 1px solid var(--ios-border);
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        
        [data-theme="dark"] .global-nav-container {
            background: rgba(28, 28, 30, 0.95);
        }
        
        .global-nav-scroll { 
            display: flex; 
            overflow-x: auto; 
            padding: 12px 16px; 
            gap: 8px; 
            scrollbar-width: none;
            white-space: nowrap;
        }
        
        .global-nav-scroll::-webkit-scrollbar {
            display: none;
        }
        
        .global-nav-item { 
            flex-shrink: 0;
            padding: 10px 16px; 
            background: var(--ios-card-bg); 
            border: 1px solid var(--ios-border);
            border-radius: 12px; 
            text-decoration: none; 
            color: var(--ios-text); 
            font-size: 14px; 
            font-weight: 500; 
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .global-nav-item:hover, 
        .global-nav-item.active { 
            background: var(--ios-primary); 
            color: white; 
            transform: translateY(-1px);
        }
        
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            padding: 20px; 
        }
        
        .ios-card { 
            background: var(--ios-card-bg); 
            border-radius: 14px; 
            padding: 20px; 
            margin: 20px 0; 
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        h1 { margin-bottom: 10px; }
        p { margin-bottom: 20px; color: var(--ios-text); opacity: 0.8; }
        
        .loading { 
            text-align: center; 
            padding: 40px; 
            color: var(--ios-text); 
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <div class="global-nav-container">
        <div class="global-nav-scroll">
            <a href="/crm" class="global-nav-item">
                <span>📊</span> CRM System
            </a>
            <a href="/admin" class="global-nav-item">
                <span>⚙️</span> Admin Panel
            </a>
            <a href="/" class="global-nav-item active">
                <span>🚀</span> API Hub
            </a>
            <a href="/web" class="global-nav-item">
                <span>🌐</span> Web Service
            </a>
        </div>
    </div>

    <div class="container">
        <div class="ios-card">
            <h1>🚀 API Hub - Центр управления каналами</h1>
            <p>Система распределения сообщений по различным каналам. Управляйте отправкой в Telegram, VK, Email и другие каналы из единого интерфейса.</p>
            
            <div class="loading">
                <p>📡 Подключаемся к API серверу...</p>
                <p>Если это сообщение не исчезает, проверьте что API сервер запущен на порту 3002.</p>
            </div>
            
            <div id="app" style="display: none;">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px;">
                    <div class="ios-card">
                        <h3>📤 Распределение</h3>
                        <p>Отправка сообщений в выбранные каналы</p>
                    </div>
                    <div class="ios-card">
                        <h3>🌐 Каналы</h3>
                        <p>Управление подключенными каналами</p>
                    </div>
                    <div class="ios-card">
                        <h3>📊 Аналитика</h3>
                        <p>Статистика отправленных сообщений</p>
                    </div>
                    <div class="ios-card">
                        <h3>📥 Сбор данных</h3>
                        <p>Прием данных из внешних источников</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Simple check if API is available
        fetch('/api/channels')
            .then(response => response.json())
            .then(data => {
                document.querySelector('.loading').style.display = 'none';
                document.getElementById('app').style.display = 'block';
                console.log('API connected:', data);
            })
            .catch(error => {
                console.error('API connection failed:', error);
                document.querySelector('.loading').innerHTML = 
                    '<p>❌ Не удалось подключиться к API серверу</p>' +
                    '<p>Проверьте что сервис API запущен.</p>';
            });
    </script>
</body>
</html>
EOF
    echo "✅ API Hub frontend recreated"
fi

# Final test
echo ""
echo "🧪 Final test - accessing API Hub..."
curl -s http://localhost/ | grep -o '<title>.*</title>' || echo "❌ Cannot access API Hub"

echo ""
echo "============================================"
echo "✅ API HUB FIXED!"
echo "============================================"
echo ""
echo "🌐 All services should now be accessible:"
echo "   🚀 API Hub:     http://212.193.26.156/"
echo "   📊 CRM:        http://212.193.26.156/crm"
echo "   ⚙️  Admin:      http://212.193.26.156/admin"
echo "   🌐 Web:         http://212.193.26.156/web"
echo ""
echo "🔧 Services Status:"
echo "   API Service: $(systemctl is-active api-service)"
echo "   Nginx: $(systemctl is-active nginx)"
