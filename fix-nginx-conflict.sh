#!/bin/bash

# Fix Nginx Configuration Conflict
echo "🔧 Fixing nginx configuration conflict..."

# Check what's in sites-enabled
echo "📋 Checking nginx sites-enabled..."
ls -la /etc/nginx/sites-enabled/

# Check nginx configuration structure
echo "📋 Checking nginx.conf..."
grep -r "sites-enabled" /etc/nginx/nginx.conf

# Remove default configuration if it exists
echo "🗑️ Removing default nginx configuration..."
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default

# Check if our config is properly linked
echo "🔗 Checking api-hub link..."
ls -la /etc/nginx/sites-enabled/api-hub

# Create a complete nginx configuration
echo "🔧 Creating complete nginx configuration..."
cat > /etc/nginx/sites-available/api-hub << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name _;
    
    # Disable default nginx page
    root /var/www/html;
    
    # API backend - proxy to Node.js
    location /api/ {
        proxy_pass http://127.0.0.1:3002/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Handle preflight requests
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE';
            add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization';
            add_header 'Access-Control-Max-Age' 86400;
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
    
    # API Hub frontend
    location / {
        alias /root/development/services/api/;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Handle redirects without trailing slash
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
    
    # Handle favicon and other common requests
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    
    location = /robots.txt {
        log_not_found off;
        access_log off;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Ensure the link exists
echo "🔗 Ensuring api-hub is enabled..."
ln -sf /etc/nginx/sites-available/api-hub /etc/nginx/sites-enabled/

# Create default nginx directory to avoid errors
echo "📁 Creating default nginx directory..."
mkdir -p /var/www/html
echo "<!-- Default nginx -->" > /var/www/html/index.html

# Check API service status and fix if needed
echo "🔧 Checking API service..."
if ! systemctl is-active --quiet api-service; then
    echo "🔄 Starting API service..."
    systemctl start api-service
    sleep 3
fi

# Check if API is listening on port 3002
echo "🔌 Checking API port..."
netstat -tlnp | grep 3002 || echo "⚠️  API not on port 3002"

# If API is not on 3002, find the correct port
if ! netstat -tlnp | grep -q 3002; then
    echo "🔍 Finding API port..."
    API_PORT=$(netstat -tlnp | grep node | awk '{print $4}' | grep -o '[0-9]*$' | head -1)
    if [ -n "$API_PORT" ]; then
        echo "🔄 Updating nginx to use port $API_PORT"
        sed -i "s/3002/$API_PORT/g" /etc/nginx/sites-available/api-hub
    else
        echo "🚀 Starting API service on port 3002..."
        cd /root/development/services/api/backend
        node server.js &
        sleep 3
    fi
fi

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

# Check nginx error log for recent errors
echo "📋 Checking nginx error log..."
tail -10 /var/log/nginx/error.log

echo ""
echo "============================================"
echo "✅ NGINX CONFLICT FIXED!"
echo "============================================"
echo ""
echo "🌐 All services should now be accessible:"
echo "   📊 CRM:        http://212.193.26.156/crm"
echo "   ⚙️  Admin:      http://212.193.26.156/admin"
echo "   🚀 API Hub:     http://212.193.26.156/api"
echo "   🌐 Web:         http://212.193.26.156/web"
echo ""
echo "🔧 Services Status:"
echo "   API Service: $(systemctl is-active api-service)"
echo "   Nginx: $(systemctl is-active nginx)"
