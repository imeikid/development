#!/bin/bash

case "$1" in
    start)
        echo "🚀 ЗАПУСК МАРКЕТИНГОВОЙ СИСТЕМЫ"
        echo "================================"
        
        # Останавливаем предыдущие экземпляры
        ./stop-all.sh
        sleep 2
        
        # Устанавливаем локаль для корректной кодировки
        export LANG=en_US.UTF-8
        export LC_ALL=en_US.UTF-8
        
        echo "🌐 Запуск лэндинга на порту 8000..."
        cd services/web
        python3 -c "
import http.server
import socketserver
import sys

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        super().end_headers()

with socketserver.TCPServer(('', 8000), MyHandler) as httpd:
    print('Сервер запущен на порту 8000')
    httpd.serve_forever()
" > ../../logs/web.log 2>&1 &
        echo $! > ../../logs/web.pid
        cd ../..
        
        echo "🔗 Запуск API на порту 8080..."
        cd services/api
        python3 -c "
import http.server
import socketserver

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        super().end_headers()

with socketserver.TCPServer(('', 8080), MyHandler) as httpd:
    print('Сервер запущен на порту 8080')
    httpd.serve_forever()
" > ../../logs/api.log 2>&1 &
        echo $! > ../../logs/api.pid
        cd ../..
        
        echo "📊 Запуск CRM на порту 8081..."
        cd services/crm
        python3 -c "
import http.server
import socketserver

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        super().end_headers()

with socketserver.TCPServer(('', 8081), MyHandler) as httpd:
    print('Сервер запущен на порту 8081')
    httpd.serve_forever()
" > ../../logs/crm.log 2>&1 &
        echo $! > ../../logs/crm.pid
        cd ../..
        
        echo "⚙️ Запуск админки на порту 8090..."
        cd services/admin
        python3 -c "
import http.server
import socketserver

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        super().end_headers()

with socketserver.TCPServer(('', 8090), MyHandler) as httpd:
    print('Сервер запущен на порту 8090')
    httpd.serve_forever()
" > ../../logs/admin.log 2>&1 &
        echo $! > ../../logs/admin.pid
        cd ../..
        
        sleep 3
        
        echo ""
        echo "✅ СИСТЕМА ЗАПУЩЕНА"
        echo "==================="
        echo "🌐 Лендинг:    http://212.193.26.156:8000"
        echo "🔗 API:        http://212.193.26.156:8080" 
        echo "📊 CRM:        http://212.193.26.156:8081"
        echo "⚙️ Админка:    http://212.193.26.156:8090"
        echo ""
        echo "💡 Кодировка UTF-8 установлена для всех сервисов"
        ;;
        
    stop)
        ./stop-all.sh
        ;;
        
    status)
        echo "📊 СТАТУС СИСТЕМЫ"
        echo "================="
        for port in 8000 8080 8081 8090; do
            if netstat -tulpn 2>/dev/null | grep -q ":$port "; then
                echo "✅ Порт $port: ЗАНЯТ"
            else
                echo "❌ Порт $port: СВОБОДЕН"
            fi
        done
        ;;
        
    *)
        echo "Использование: $0 {start|stop|status}"
        echo "🚀 start    - запуск всей системы"
        echo "🛑 stop     - остановка системы"
        echo "📊 status   - статус портов"
        ;;
esac
