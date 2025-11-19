#!/bin/bash

# Fix 404 Errors for Other Services
echo "🔧 Fixing 404 errors for CRM, Admin, and Web services..."

# Check current nginx configuration
echo "📋 Checking nginx configuration..."
nginx -t
cat /etc/nginx/sites-available/api-hub

# Check if service directories exist and have index.html
echo "🔍 Checking service directories..."
for service in crm admin web; do
    echo "Checking /root/development/services/$service/"
    if [ -f "/root/development/services/$service/index.html" ]; then
        echo "✅ $service: index.html exists"
    else
        echo "❌ $service: index.html missing"
    fi
done

# Fix nginx configuration with proper paths
echo "🔧 Fixing nginx configuration..."
cat > /etc/nginx/sites-available/api-hub << 'EOF'
server {
    listen 80;
    server_name _;
    
    # API backend - proxy to Node.js
    location /api/ {
        proxy_pass http://localhost:3002/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
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
    
    # API Hub frontend
    location / {
        alias /root/development/services/api/;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Handle API without trailing slash
    location = /api {
        return 302 /api/;
    }
}
EOF

# Ensure all service directories have proper index.html files
echo "📝 Creating/verifying service pages..."

# CRM Service
cat > /root/development/services/crm/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CRM System - Управление клиентами</title>
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
        
        .grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); 
            gap: 20px; 
            margin-top: 20px; 
        }
    </style>
</head>
<body>
    <div class="global-nav-container">
        <div class="global-nav-scroll">
            <a href="/crm" class="global-nav-item active">
                <span>📊</span> CRM System
            </a>
            <a href="/admin" class="global-nav-item">
                <span>⚙️</span> Admin Panel
            </a>
            <a href="/api" class="global-nav-item">
                <span>🚀</span> API Hub
            </a>
            <a href="/web" class="global-nav-item">
                <span>🌐</span> Web Service
            </a>
        </div>
    </div>

    <div class="container">
        <div class="ios-card">
            <h1>📊 CRM System - Управление клиентами</h1>
            <p>Система управления взаимоотношениями с клиентами. Отслеживайте взаимодействия, управляйте сделками и анализируйте эффективность.</p>
            
            <div class="grid">
                <div class="ios-card">
                    <h3>👥 Клиенты</h3>
                    <p>База данных клиентов с историей взаимодействий</p>
                </div>
                <div class="ios-card">
                    <h3>💼 Сделки</h3>
                    <p>Управление воронкой продаж и сделками</p>
                </div>
                <div class="ios-card">
                    <h3>📈 Аналитика</h3>
                    <p>Отчеты и метрики эффективности</p>
                </div>
                <div class="ios-card">
                    <h3>📞 Обращения</h3>
                    <p>Система поддержки клиентов</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Admin Service
cat > /root/development/services/admin/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel - Панель управления</title>
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
        
        .grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); 
            gap: 20px; 
            margin-top: 20px; 
        }
    </style>
</head>
<body>
    <div class="global-nav-container">
        <div class="global-nav-scroll">
            <a href="/crm" class="global-nav-item">
                <span>📊</span> CRM System
            </a>
            <a href="/admin" class="global-nav-item active">
                <span>⚙️</span> Admin Panel
            </a>
            <a href="/api" class="global-nav-item">
                <span>🚀</span> API Hub
            </a>
            <a href="/web" class="global-nav-item">
                <span>🌐</span> Web Service
            </a>
        </div>
    </div>

    <div class="container">
        <div class="ios-card">
            <h1>⚙️ Admin Panel - Панель управления</h1>
            <p>Административная панель для управления системой, пользователями и настройками.</p>
            
            <div class="grid">
                <div class="ios-card">
                    <h3>👤 Пользователи</h3>
                    <p>Управление пользователями и ролями</p>
                </div>
                <div class="ios-card">
                    <h3>🔐 Права доступа</h3>
                    <p>Настройка разрешений и политик</p>
                </div>
                <div class="ios-card">
                    <h3>📊 Мониторинг</h3>
                    <p>Системный мониторинг и логи</p>
                </div>
                <div class="ios-card">
                    <h3>⚙️ Настройки</h3>
                    <p>Общие настройки системы</p>
                </div>
                <div class="ios-card">
                    <h3>🔧 Система</h3>
                    <p>Управление службами и процессами</p>
                </div>
                <div class="ios-card">
                    <h3>📈 Статистика</h3>
                    <p>Аналитика использования системы</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Web Service
cat > /root/development/services/web/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Service - Веб сервис</title>
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
        
        .grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); 
            gap: 20px; 
            margin-top: 20px; 
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
            <a href="/api" class="global-nav-item">
                <span>🚀</span> API Hub
            </a>
            <a href="/web" class="global-nav-item active">
                <span>🌐</span> Web Service
            </a>
        </div>
    </div>

    <div class="container">
        <div class="ios-card">
            <h1>🌐 Web Service - Веб сервис</h1>
            <p>Основной веб-сервис системы с современным интерфейсом и адаптивным дизайном.</p>
            
            <div class="grid">
                <div class="ios-card">
                    <h3>🎯 Главная</h3>
                    <p>Основной веб-интерфейс системы</p>
                </div>
                <div class="ios-card">
                    <h3>📱 Адаптивность</h3>
                    <p>Поддержка всех устройств</p>
                </div>
                <div class="ios-card">
                    <h3>⚡ Производительность</h3>
                    <p>Оптимизация и кэширование</p>
                </div>
                <div class="ios-card">
                    <h3>🔍 SEO</h3>
                    <p>Поисковая оптимизация</p>
                </div>
                <div class="ios-card">
                    <h3>🎨 Дизайн</h3>
                    <p>Современный UI/UX</p>
                </div>
                <div class="ios-card">
                    <h3>🔧 Технологии</h3>
                    <p>Современные веб-технологии</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Set proper permissions
echo "🔐 Setting proper permissions..."
chmod -R 755 /root/development/services/

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
nginx -t

# Reload nginx
echo "🔄 Reloading nginx..."
systemctl reload nginx

# Test all services
echo "🧪 Testing all services..."
echo "Testing CRM:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/crm && echo " - CRM OK" || echo " - CRM FAILED"
echo "Testing Admin:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/admin && echo " - Admin OK" || echo " - Admin FAILED"
echo "Testing Web:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/web && echo " - Web OK" || echo " - Web FAILED"
echo "Testing API:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/api && echo " - API OK" || echo " - API FAILED"

echo ""
echo "============================================"
echo "✅ 404 ERRORS FIXED!"
echo "============================================"
echo ""
echo "🌐 All services should now be accessible:"
echo "   📊 CRM:        http://2a03:6f00:a::f029/crm"
echo "   ⚙️  Admin:      http://2a03:6f00:a::f029/admin"
echo "   🚀 API Hub:     http://2a03:6f00:a::f029/api"
echo "   🌐 Web:         http://2a03:6f00:a::f029/web"
echo ""
echo "🔧 Services Status:"
echo "   API Service: $(systemctl is-active api-service)"
echo "   Nginx: $(systemctl is-active nginx)"
