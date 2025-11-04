#!/bin/bash

echo "🛑 Останавливаем все сервисы..."

# Убиваем процессы на наших портах
sudo fuser -k 8000/tcp 2>/dev/null
sudo fuser -k 8080/tcp 2>/dev/null
sudo fuser -k 8081/tcp 2>/dev/null
sudo fuser -k 8090/tcp 2>/dev/null

# Убиваем процессы Python
pkill -f "python3 -m http.server" 2>/dev/null

# Очищаем PID файлы
rm -f logs/*.pid 2>/dev/null

echo "✅ Все сервисы остановлены"
