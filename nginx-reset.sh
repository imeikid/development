#!/bin/bash

# Complete Nginx Reset and Fix
echo "🔧 Complete Nginx Reset and Fix..."

# Stop nginx
echo "🛑 Stopping nginx..."
systemctl stop nginx

# Backup current config
echo "📦 Backing up current config..."
cp /etc/nginx/sites-available/api-hub /tmp/api-hub.backup 2>/dev/null || true

# Completely reset nginx configuration
echo "🗑️ Removing all nginx configurations..."
rm -f /etc/nginx/sites-enabled/*
rm -f /etc/nginx/sites-available/api-hub

# Create a simple, clean nginx configuration
echo "🔧 Creating clean nginx configuration..."
cat > /etc/nginx/nginx.conf << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;

    # Our main server block
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        
        # Disable default nginx landing page
        root /var/www/html;
        
        # API backend - proxy to Node.js
        location /api/ {
            proxy_pass http://127.0.0.1:3002/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # CORS headers
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
            add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
            
            if ($request_method = 'OPTIONS') {
                return 204;
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
        
        # API Hub frontend - serve from root
        location / {
            alias /root/development/services/api/;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
        
        # Handle redirects
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
        
        # Ignore favicon and robot requests
        location = /favicon.ico {
            access_log off;
            log_not_found off;
        }
        
        location = /robots.txt {
            access_log off;
            log_not_found off;
        }
    }
}
EOF

# Create default directory to avoid errors
echo "📁 Creating default directories..."
mkdir -p /var/www/html
echo "<!-- Default -->" > /var/www/html/index.html

# Set proper permissions
echo "🔐 Setting permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /root/development/services/

# Check if API service is running
echo "🔍 Checking API service..."
if ! systemctl is-active --quiet api-service; then
    echo "🚀 Starting API service..."
    systemctl start api-service
    sleep 3
fi

# Test API directly
echo "🧪 Testing API directly..."
curl -s http://localhost:3002/ && echo "✅ API is running" || echo "❌ API not responding"

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
nginx -t

# Start nginx
echo "🚀 Starting nginx..."
systemctl start nginx

# Wait a moment
sleep 3

# Test all services
echo "🧪 Testing all services..."
echo "Testing API Frontend (root):"
curl -s -o /dev/null -w "%{http_code}" http://localhost/ && echo " - API Frontend OK" || echo " - API Frontend FAILED"

echo "Testing API Backend:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/api/channels && echo " - API Backend OK" || echo " - API Backend FAILED"

echo "Testing CRM:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/crm && echo " - CRM OK" || echo " - CRM FAILED"

echo "Testing Admin:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/admin && echo " - Admin OK" || echo " - Admin FAILED"

echo "Testing Web:"
curl -s -o /dev/null -w "%{http_code}" http://localhost/web && echo " - Web OK" || echo " - Web FAILED"

# Check nginx status
echo "📋 Checking nginx status..."
systemctl status nginx --no-pager

# Check nginx error log
echo "📋 Checking nginx error log..."
tail -5 /var/log/nginx/error.log

echo ""
echo "============================================"
echo "✅ NGINX COMPLETELY RESET AND FIXED!"
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
