#!/bin/bash

echo "🔧 НАСТРОЙКА GITHUB РЕПОЗИТОРИЯ"
echo "================================"

# Базовая настройка Git
git config --global user.name "imeikid"
git config --global user.email "gromovoivik@yahoo.com"
git config --global init.defaultBranch main

echo "✅ Git сконфигурирован:"
echo "   👤 Имя: imeikid"
echo "   📧 Email: gromovoivik@yahoo.com"
echo "   🌿 Ветка по умолчанию: main"

# Проверяем инициализацию репозитория
if [ ! -d ".git" ]; then
    echo "🔄 Инициализируем Git репозиторий..."
    git init
    git add .
    git commit -m "Initial commit: Marketing System Project"
    echo "✅ Репозиторий инициализирован"
else
    echo "✅ Git репозиторий уже инициализирован"
fi

# Проверяем remote
if ! git remote | grep -q origin; then
    echo "🌐 Настраиваем подключение к GitHub..."
    git remote add origin https://github.com/imeikid/development.git
    echo "✅ Remote origin добавлен"
else
    echo "✅ Remote origin уже настроен"
    git remote -v
fi

echo ""
echo "📋 ДАЛЬНЕЙШИЕ ШАГИ:"
echo "==================="
echo "1. Убедитесь что репозиторий существует: https://github.com/imeikid/development"
echo "2. Если репозитория нет, создайте его на GitHub"
echo "3. Запустите: ./update-github.sh"
echo "4. При запросе пароля используйте Personal Access Token"
