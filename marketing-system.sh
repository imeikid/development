#!/bin/bash
echo "🚀 Запуск маркетинг системы на 212.193.26.156"

# Создаем структуру папок
mkdir -p {sites,data,logs}

# Проверяем доступные порты
check_ports() {
    echo "🔍 Проверка портов..."
    for port in 8000 8080 8081 8090; do
        if nc -z 127.0.0.1 $port 2>/dev/null; then
            echo "⚠️  Порт $port занят"
        else
            echo "✅ Порт $port свободен"
        fi
    done
}

# Простой HTTP сервер на bash
start_web_server() {
    echo "🌐 Запуск веб-сервера на порту 8000..."
    
    # Создаем простой сайт
    mkdir -p sites/default
    cat > sites/default/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Маркетинг Система</title>
    <style>
        body { font-family: Arial; margin: 40px; background: #f0f2f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; }
        .form-group { margin: 15px 0; }
        input, textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        button { background: #007cba; color: white; padding: 12px 30px; border: none; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Система запущена!</h1>
        <p>Маркетинг система работает на вашем сервере.</p>
        
        <h3>📝 Тестовая форма:</h3>
        <form onsubmit="alert('Форма работает!'); return false;">
            <div class="form-group">
                <input type="text" placeholder="Ваше имя">
            </div>
            <div class="form-group">
                <input type="tel" placeholder="Телефон">
            </div>
            <button type="submit">Отправить</button>
        </form>
        
        <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
            <h3>🔗 Доступные сервисы:</h3>
            <ul>
                <li><a href="http://212.193.26.156:8000">Веб-сайт (порт 8000)</a></li>
                <li><a href="http://212.193.26.156:8080">API (порт 8080)</a></li>
                <li><a href="http://212.193.26.156:8081">CRM (порт 8081)</a></li>
                <li><a href="http://212.193.26.156:8090">Админка (порт 8090)</a></li>
            </ul>
        </div>
    </div>
</body>
</html>
HTML

    # Запускаем простой HTTP сервер используя netcat
    while true; do
        echo "HTTP/1.1 200 OK\nContent-Type: text/html\n\n$(cat sites/default/index.html)" | nc -l -p 8000 -q 1
    done &
    echo $! > logs/web.pid
    echo "✅ Веб-сервер запущен (PID: $(cat logs/web.pid))"
}

# Простой API сервер
start_api_server() {
    echo "🔗 Запуск API сервера на порту 8080..."
    
    while true; do
        echo "HTTP/1.1 200 OK\nContent-Type: application/json\n\n{\"status\":\"success\",\"message\":\"API работает\",\"timestamp\":\"$(date)\"}" | nc -l -p 8080 -q 1
    done &
    echo $! > logs/api.pid
    echo "✅ API сервер запущен (PID: $(cat logs/api.pid))"
}

# Простой CRM сервер
start_crm_server() {
    echo "📊 Запуск CRM сервера на порту 8081..."
    
    CRM_HTML='<!DOCTYPE html><html><head><title>CRM</title><style>body{font-family:Arial;margin:20px;}</style></head><body><h1>📊 CRM Система</h1><p>CRM панель управления</p><p><a href="/">На главную</a></p></body></html>'
    
    while true; do
        echo -e "HTTP/1.1 200 OK\nContent-Type: text/html\n\n$CRM_HTML" | nc -l -p 8081 -q 1
    done &
    echo $! > logs/crm.pid
    echo "✅ CRM сервер запущен (PID: $(cat logs/crm.pid))"
}

# Админ панель
start_admin_panel() {
    echo "⚙️ Запуск админ-панели на порту 8090..."
    
    ADMIN_HTML='<!DOCTYPE html><html><head><title>Admin</title><style>body{font-family:Arial;margin:20px;}.service{margin:10px 0;padding:10px;background:#f5f5f5;}</style></head><body><h1>⚙️ Админ-панель</h1><div class="service"><h3>🌐 Веб-сервер</h3><p>Порт: 8000 - <span style="color:green">Online</span></p></div><div class="service"><h3>🔗 API</h3><p>Порт: 8080 - <span style="color:green">Online</span></p></div><div class="service"><h3>📊 CRM</h3><p>Порт: 8081 - <span style="color:green">Online</span></p></div><p><strong>IP:</strong> 212.193.26.156</p></body></html>'
    
    while true; do
        echo -e "HTTP/1.1 200 OK\nContent-Type: text/html\n\n$ADMIN_HTML" | nc -l -p 8090 -q 1
    done &
    echo $! > logs/admin.pid
    echo "✅ Админ-панель запущена (PID: $(cat logs/admin.pid))"
}

# Остановка всех сервисов
stop_services() {
    echo "🛑 Остановка сервисов..."
    for service in web api crm admin; do
        if [ -f "logs/$service.pid" ]; then
            pid=$(cat logs/$service.pid)
            kill $pid 2>/dev/null && echo "✅ Остановлен $service (PID: $pid)" || echo "⚠️  $service уже остановлен"
            rm -f logs/$service.pid
        fi
    done
}

# Проверка статуса
status_services() {
    echo "📊 Статус сервисов:"
    for service in web api crm admin; do
        if [ -f "logs/$service.pid" ] && kill -0 $(cat logs/$service.pid) 2>/dev/null; then
            echo "✅ $service: ЗАПУЩЕН (PID: $(cat logs/$service.pid))"
        else
            echo "❌ $service: ОСТАНОВЛЕН"
        fi
    done
}

# Основное меню
case "${1:-}" in
    "start")
        check_ports
        start_web_server
        start_api_server
        start_crm_server
        start_admin_panel
        echo ""
        echo "🎉 СИСТЕМА ЗАПУЩЕНА!"
        echo "🌐 Сайт: http://212.193.26.156:8000"
        echo "🔗 API: http://212.193.26.156:8080" 
        echo "📊 CRM: http://212.193.26.156:8081"
        echo "⚙️  Админ: http://212.193.26.156:8090"
        echo ""
        echo "💡 Для остановки: ./marketing-system.sh stop"
        ;;
    "stop")
        stop_services
        ;;
    "status")
        status_services
        ;;
    *)
        echo "Использование: $0 {start|stop|status}"
        echo ""
        echo "🚀 Быстрый старт:"
        echo "  ./marketing-system.sh start  - запуск системы"
        echo "  ./marketing-system.sh stop   - остановка системы"
        echo "  ./marketing-system.sh status - статус системы"
        ;;
esac
