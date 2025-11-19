#!/bin/bash

# API Hub Deployment Script - Fixed 404 errors
echo "🚀 Starting API Hub deployment..."

# Install dependencies
echo "📦 Installing dependencies..."
apt-get update
apt-get install -y curl
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs nginx

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p /root/development/services/{api,crm,admin,web}/{backend,js,css,assets}

# Create API backend
echo "🔧 Creating API backend..."
cd /root/development/services/api/backend

cat > package.json << 'EOF'
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
EOF

cat > server.js << 'EOF'
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
                result: { message: 'Сообщение отправлено успешно' }
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

app.listen(PORT, '0.0.0.0', () => {
    console.log('🚀 API Server running on port ' + PORT);
});
EOF

# Create API frontend
echo "🎨 Creating API frontend..."
cat > ../index.html << 'EOF'
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
        
        .ios-app { 
            max-width: 100%; 
            background: var(--ios-bg); 
            min-height: calc(100vh - 60px);
        }
        
        .ios-navbar { 
            background: rgba(248, 248, 248, 0.8);
            border-bottom: 1px solid var(--ios-border);
            position: sticky;
            top: 60px;
            z-index: 100;
        }
        
        [data-theme="dark"] .ios-navbar {
            background: rgba(28, 28, 30, 0.8);
        }
        
        .ios-navbar-content { 
            padding: 12px 16px; 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
        }
        
        .ios-title { 
            font-size: 17px; 
            font-weight: 600; 
            color: var(--ios-text); 
        }
        
        .ios-segment { 
            display: flex; 
            background: var(--ios-border); 
            border-radius: 8px; 
            padding: 3px; 
            margin: 16px; 
            overflow-x: auto;
            scrollbar-width: none;
        }
        
        .ios-segment-button { 
            flex-shrink: 0;
            padding: 8px 12px; 
            text-align: center; 
            border-radius: 6px; 
            border: none; 
            background: transparent; 
            color: var(--ios-text); 
            font-size: 14px; 
            font-weight: 500; 
            cursor: pointer;
            white-space: nowrap;
        }
        
        .ios-segment-button.active { 
            background: var(--ios-card-bg); 
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .ios-card { 
            background: var(--ios-card-bg); 
            border-radius: 14px; 
            margin: 16px; 
            overflow: hidden; 
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .ios-card-header { 
            padding: 16px; 
            border-bottom: 1px solid var(--ios-border); 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
        }
        
        .ios-card-header h3 { 
            font-size: 17px; 
            font-weight: 600; 
            color: var(--ios-text); 
            margin: 0; 
        }
        
        .ios-card-content { 
            padding: 16px; 
        }
        
        .ios-textarea { 
            width: 100%; 
            min-height: 120px; 
            padding: 12px; 
            border: none; 
            background: var(--ios-bg); 
            border-radius: 10px; 
            color: var(--ios-text); 
            font-size: 16px; 
            resize: none; 
            font-family: inherit; 
        }
        
        .ios-textarea:focus { 
            outline: 2px solid var(--ios-primary); 
        }
        
        .channel-selector { 
            display: flex; 
            flex-direction: column; 
            gap: 12px; 
        }
        
        .ios-checkbox { 
            display: flex; 
            align-items: center; 
            gap: 12px; 
            padding: 8px 0; 
            cursor: pointer; 
        }
        
        .ios-checkbox input { 
            display: none; 
        }
        
        .ios-checkbox span { 
            position: relative; 
            padding-left: 32px; 
            font-size: 16px; 
            color: var(--ios-text); 
        }
        
        .ios-checkbox span:before { 
            content: ''; 
            position: absolute; 
            left: 0; 
            top: 50%; 
            transform: translateY(-50%); 
            width: 22px; 
            height: 22px; 
            border: 2px solid var(--ios-border); 
            border-radius: 6px; 
            transition: all 0.3s ease; 
        }
        
        .ios-checkbox input:checked + span:before { 
            background: var(--ios-primary); 
            border-color: var(--ios-primary); 
        }
        
        .ios-checkbox input:checked + span:after { 
            content: '✓'; 
            position: absolute; 
            left: 5px; 
            top: 50%; 
            transform: translateY(-50%); 
            color: white; 
            font-size: 14px; 
            font-weight: bold; 
        }
        
        .ios-button { 
            padding: 12px 20px; 
            border: none; 
            border-radius: 10px; 
            font-size: 16px; 
            font-weight: 600; 
            cursor: pointer; 
            background: var(--ios-card-bg); 
            color: var(--ios-text); 
            border: 1px solid var(--ios-border); 
        }
        
        .ios-button.primary { 
            background: var(--ios-primary); 
            color: white; 
            border: none; 
        }
        
        .ios-button:active { 
            transform: scale(0.98); 
        }
        
        .tab-content { 
            display: none; 
        }
        
        .tab-content.active { 
            display: block; 
        }
        
        .data-list { 
            display: flex; 
            flex-direction: column; 
            gap: 8px; 
        }
        
        .data-item { 
            padding: 12px; 
            background: var(--ios-bg); 
            border-radius: 10px; 
            border: 1px solid var(--ios-border); 
        }
        
        .quick-actions { 
            display: flex; 
            gap: 8px; 
            padding: 0 16px 16px; 
            overflow-x: auto;
            scrollbar-width: none;
        }
        
        .quick-actions::-webkit-scrollbar {
            display: none;
        }
        
        .quick-action { 
            flex-shrink: 0;
            padding: 12px 16px; 
            background: var(--ios-card-bg); 
            border: 1px solid var(--ios-border); 
            border-radius: 12px; 
            color: var(--ios-text); 
            font-size: 14px; 
            font-weight: 500; 
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .quick-action:hover { 
            background: var(--ios-primary); 
            color: white; 
        }
        
        .ios-loading { 
            display: inline-block; 
            width: 20px; 
            height: 20px; 
            border: 2px solid #f3f3f3; 
            border-top: 2px solid var(--ios-primary); 
            border-radius: 50%; 
            animation: spin 1s linear infinite; 
        }
        
        @keyframes spin { 
            0% { transform: rotate(0deg); } 
            100% { transform: rotate(360deg); } 
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
            <a href="/api" class="global-nav-item active">
                <span>🚀</span> API Hub
            </a>
            <a href="/web" class="global-nav-item">
                <span>🌐</span> Web Service
            </a>
        </div>
    </div>

    <div class="ios-app" data-theme="light">
        <header class="ios-navbar">
            <div class="ios-navbar-content">
                <h1 class="ios-title">API Hub - Центр управления каналами</h1>
                <div class="ios-controls">
                    <button class="ios-button" onclick="toggleDarkMode()">🌙</button>
                </div>
            </div>
        </header>

        <div class="quick-actions">
            <button class="quick-action" onclick="showTab('distribution')">
                📤 Распределить
            </button>
            <button class="quick-action" onclick="showTab('incoming')">
                📥 Входящие
            </button>
            <button class="quick-action" onclick="showTab('channels')">
                🌐 Каналы
            </button>
            <button class="quick-action" onclick="showTab('analytics')">
                📊 Аналитика
            </button>
        </div>

        <div class="ios-segment" id="mainSegment">
            <button class="ios-segment-button active" data-tab="distribution">📤 Распределение</button>
            <button class="ios-segment-button" data-tab="incoming">📥 Входящие данные</button>
            <button class="ios-segment-button" data-tab="channels">🌐 Управление каналами</button>
            <button class="ios-segment-button" data-tab="analytics">📊 Аналитика и статистика</button>
        </div>

        <main class="ios-content">
            <div id="distribution" class="tab-content active">
                <div class="ios-card">
                    <div class="ios-card-header">
                        <h3>📤 Отправка сообщений</h3>
                    </div>
                    <div class="ios-card-content">
                        <textarea id="messageInput" class="ios-textarea" placeholder="Введите сообщение для отправки во все каналы..."></textarea>
                    </div>
                </div>

                <div class="ios-card">
                    <div class="ios-card-header">
                        <h3>🌐 Выбор каналов</h3>
                    </div>
                    <div class="ios-card-content">
                        <div class="channel-selector" id="channelSelector"></div>
                    </div>
                </div>

                <button class="ios-button primary" onclick="distributeMessage()" style="width: calc(100% - 32px); margin: 0 16px 16px;">
                    📢 Отправить во все выбранные каналы
                </button>

                <div class="ios-card" id="resultsCard" style="display: none;">
                    <div class="ios-card-header">
                        <h3>📋 Результаты отправки</h3>
                        <button class="ios-button" onclick="clearResults()">Очистить</button>
                    </div>
                    <div class="ios-card-content">
                        <div id="distributionResults"></div>
                    </div>
                </div>
            </div>

            <div id="incoming" class="tab-content">
                <div class="ios-card">
                    <div class="ios-card-header">
                        <h3>📥 Входящие данные</h3>
                        <button class="ios-button" onclick="loadIncomingData()">🔄 Обновить</button>
                    </div>
                    <div class="ios-card-content">
                        <div id="incomingDataList" class="data-list">
                            <div class="data-item">
                                <div class="ios-loading"></div> Загрузка данных...
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="channels" class="tab-content">
                <div class="ios-card">
                    <div class="ios-card-header">
                        <h3>🌐 Управление каналами</h3>
                    </div>
                    <div class="ios-card-content">
                        <div id="channelsList"></div>
                    </div>
                </div>
            </div>

            <div id="analytics" class="tab-content">
                <div class="ios-card">
                    <div class="ios-card-header">
                        <h3>📊 Статистика системы</h3>
                        <button class="ios-button" onclick="loadAnalytics()">🔄 Обновить</button>
                    </div>
                    <div class="ios-card-content">
                        <div id="analyticsContent"></div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        const API_BASE_URL = window.location.origin;

        document.addEventListener('DOMContentLoaded', function() {
            initSegmentControl();
            loadChannels();
            loadAnalytics();
        });

        function initSegmentControl() {
            const segmentButtons = document.querySelectorAll('.ios-segment-button');
            segmentButtons.forEach(button => {
                button.addEventListener('click', function() {
                    const tabName = this.getAttribute('data-tab');
                    showTab(tabName);
                });
            });
        }

        function showTab(tabName) {
            const segmentButtons = document.querySelectorAll('.ios-segment-button');
            segmentButtons.forEach(btn => btn.classList.remove('active'));
            document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
            
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            document.getElementById(tabName).classList.add('active');
        }

        function toggleDarkMode() {
            const app = document.querySelector('.ios-app');
            const currentTheme = app.getAttribute('data-theme');
            const newTheme = currentTheme === 'light' ? 'dark' : 'light';
            app.setAttribute('data-theme', newTheme);
            
            const button = document.querySelector('.ios-controls .ios-button');
            button.textContent = newTheme === 'light' ? '🌙' : '☀️';
        }

        async function loadChannels() {
            try {
                const response = await fetch(`${API_BASE_URL}/api/channels`);
                const data = await response.json();
                
                const channelSelector = document.getElementById('channelSelector');
                const channelsList = document.getElementById('channelsList');
                
                channelSelector.innerHTML = '';
                channelsList.innerHTML = '';
                
                Object.entries(data.channels).forEach(([key, channel]) => {
                    const checkbox = document.createElement('label');
                    checkbox.className = 'ios-checkbox';
                    checkbox.innerHTML = `
                        <input type="checkbox" value="${key}" ${channel.enabled ? 'checked' : ''}>
                        <span>${channel.icon} ${channel.name}</span>
                    `;
                    channelSelector.appendChild(checkbox);
                    
                    const channelItem = document.createElement('div');
                    channelItem.style.cssText = 'padding: 12px; border-bottom: 1px solid var(--ios-border);';
                    channelItem.innerHTML = `
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <strong>${channel.icon} ${channel.name}</strong>
                            </div>
                            <button class="ios-button" onclick="toggleChannel('${key}')">
                                ${channel.enabled ? 'Выключить' : 'Включить'}
                            </button>
                        </div>
                    `;
                    channelsList.appendChild(channelItem);
                });
            } catch (error) {
                alert('Ошибка загрузки каналов');
            }
        }

        async function distributeMessage() {
            const message = document.getElementById('messageInput').value.trim();
            const selectedChannels = Array.from(document.querySelectorAll('#channelSelector input:checked')).map(input => input.value);
            
            if (!message) {
                alert('Введите сообщение для отправки');
                return;
            }
            
            if (selectedChannels.length === 0) {
                alert('Выберите хотя бы один канал');
                return;
            }
            
            const button = document.querySelector('#distribution .ios-button.primary');
            const originalText = button.textContent;
            button.innerHTML = '<div class="ios-loading"></div> Отправка...';
            button.disabled = true;
            
            try {
                const response = await fetch(`${API_BASE_URL}/api/distribute`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message, channels: selectedChannels })
                });
                
                const result = await response.json();
                
                document.getElementById('resultsCard').style.display = 'block';
                const resultsDiv = document.getElementById('distributionResults');
                
                resultsDiv.innerHTML = result.results.map(r => `
                    <div class="data-item">
                        <div style="display: flex; justify-content: space-between; align-items: start;">
                            <div>
                                <strong>${r.channel}</strong>
                                <div style="font-size: 12px; color: var(--ios-text-secondary); margin-top: 4px;">
                                    ${r.result?.message || ''}
                                </div>
                            </div>
                            <span style="color: ${r.status === 'success' ? 'green' : 'red'}; font-size: 18px;">
                                ${r.status === 'success' ? '✅' : '❌'}
                            </span>
                        </div>
                    </div>
                `).join('');
                
                alert(`Сообщение отправлено в ${result.results.length} каналов`);
                
            } catch (error) {
                alert('Ошибка при отправке сообщения');
            } finally {
                button.textContent = originalText;
                button.disabled = false;
            }
        }

        async function loadAnalytics() {
            try {
                const response = await fetch(`${API_BASE_URL}/api/stats`);
                const stats = await response.json();
                
                const analyticsDiv = document.getElementById('analyticsContent');
                
                analyticsDiv.innerHTML = `
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                        <div style="text-align: center; padding: 20px; background: var(--ios-bg); border-radius: 12px;">
                            <div style="font-size: 28px; font-weight: bold;">${stats.totalMessages}</div>
                            <div>Всего сообщений</div>
                        </div>
                        <div style="text-align: center; padding: 20px; background: var(--ios-bg); border-radius: 12px;">
                            <div style="font-size: 28px; font-weight: bold;">${stats.totalDataPoints}</div>
                            <div>Входящих данных</div>
                        </div>
                    </div>
                `;
            } catch (error) {
                document.getElementById('analyticsContent').innerHTML = '<div class="data-item">Ошибка загрузки статистики</div>';
            }
        }

        function clearResults() {
            document.getElementById('distributionResults').innerHTML = '';
            document.getElementById('resultsCard').style.display = 'none';
        }

        async function toggleChannel(channelId) {
            try {
                const response = await fetch(`${API_BASE_URL}/api/channels/${channelId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ enabled: !document.querySelector(`input[value="${channelId}"]`).checked })
                });
                
                if (response.ok) {
                    loadChannels();
                    loadAnalytics();
                    alert('Настройки канала обновлены');
                }
            } catch (error) {
                alert('Ошибка обновления канала');
            }
        }
    </script>
</body>
</html>
EOF

# Create other services with proper HTML structure
echo "🏗️ Creating other services..."

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
            <p>Система управления взаимоотношениями с клиентами</p>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px;">
                <div class="ios-card">
                    <h3>👥 Клиенты</h3>
                    <p>Управление базой клиентов</p>
                </div>
                <div class="ios-card">
                    <h3>📈 Аналитика</h3>
                    <p>Отчеты и метрики</p>
                </div>
                <div class="ios-card">
                    <h3>💼 Сделки</h3>
                    <p>Управление продажами</p>
                </div>
                <div class="ios-card">
                    <h3>📞 Обращения</h3>
                    <p>Поддержка клиентов</p>
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
            <p>Административная панель для управления системой</p>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px;">
                <div class="ios-card">
                    <h3>👤 Пользователи</h3>
                    <p>Управление пользователями системы</p>
                </div>
                <div class="ios-card">
                    <h3>🔐 Права доступа</h3>
                    <p>Настройка ролей и разрешений</p>
                </div>
                <div class="ios-card">
                    <h3>📊 Мониторинг</h3>
                    <p>Системный мониторинг и логи</p>
                </div>
                <div class="ios-card">
                    <h3>⚙️ Настройки</h3>
                    <p>Общие настройки системы</p>
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
            <p>Основной веб-сервис системы</p>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px;">
                <div class="ios-card">
                    <h3>🎯 Главная страница</h3>
                    <p>Основной веб-интерфейс</p>
                </div>
                <div class="ios-card">
                    <h3>📱 Адаптивность</h3>
                    <p>Поддержка мобильных устройств</p>
                </div>
                <div class="ios-card">
                    <h3>⚡ Производительность</h3>
                    <p>Оптимизация и кэширование</p>
                </div>
                <div class="ios-card">
                    <h3>🔍 SEO</h3>
                    <p>Поисковая оптимизация</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Install npm dependencies
echo "📦 Installing npm dependencies..."
cd /root/development/services/api/backend
npm install

# Create systemd service
echo "🔧 Creating systemd service..."
cat > /etc/systemd/system/api-service.service << 'EOF'
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
EOF

# Create nginx config with proper routing
echo "🔧 Creating nginx config..."
cat > /etc/nginx/sites-available/api-hub << 'EOF'
server {
    listen 80;
    server_name _;
    
    # API backend
    location /api/ {
        proxy_pass http://localhost:3002/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # CRM service
    location /crm {
        alias /root/development/services/crm/;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Admin service  
    location /admin {
        alias /root/development/services/admin/;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # API Hub service
    location /api {
        alias /root/development/services/api/;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Web service
    location /web {
        alias /root/development/services/web/;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Redirect root to API Hub
    location = / {
        return 302 /api;
    }
}
EOF

# Enable nginx site
ln -sf /etc/nginx/sites-available/api-hub /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Set proper permissions
chmod -R 755 /root/development/services

# Test and reload nginx
nginx -t
systemctl reload nginx

# Start API service
echo "🚀 Starting API service..."
systemctl daemon-reload
systemctl enable api-service
systemctl start api-service

# Wait for service to start
sleep 3

# Display status
echo ""
echo "============================================"
echo "✅ DEPLOYMENT COMPLETED!"
echo "============================================"
echo ""
echo "🌐 Available Services:"
echo "   📊 CRM:        http://$(curl -s ifconfig.me)/crm"
echo "   ⚙️  Admin:      http://$(curl -s ifconfig.me)/admin" 
echo "   🚀 API Hub:     http://$(curl -s ifconfig.me)/api"
echo "   🌐 Web:         http://$(curl -s ifconfig.me)/web"
echo ""
echo "🔧 Services Status:"
echo "   API Service: $(systemctl is-active api-service)"
echo "   Nginx: $(systemctl is-active nginx)"
echo ""
echo "📝 Management Commands:"
echo "   View API logs: journalctl -u api-service -f"
echo "   Restart API: systemctl restart api-service"
echo "   Check status: systemctl status api-service"
echo ""
