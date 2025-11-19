const express = require('express');
const app = express();
const PORT = 3003;

// Middleware
app.use(express.json());
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', '*');
    res.header('Access-Control-Allow-Methods', '*');
    next();
});

// Данные каналов
const channels = [
    { id: 'telegram', name: 'Telegram', enabled: true, icon: '📱' },
    { id: 'vk', name: 'VKontakte', enabled: true, icon: '👥' },
    { id: 'email', name: 'Email', enabled: true, icon: '📧' },
    { id: 'whatsapp', name: 'WhatsApp', enabled: false, icon: '💬' }
];

// КРИТИЧЕСКИ ВАЖНО: эндпоинты с префиксом /api
app.get('/api/channels', (req, res) => {
    console.log('GET /api/channels - FIXED');
    res.json({ 
        success: true, 
        channels: channels,
        message: "Channels data loaded successfully"
    });
});

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', service: 'api', timestamp: new Date().toISOString() });
});

app.get('/api/', (req, res) => {
    res.json({ 
        message: 'API Root', 
        endpoints: ['/api/channels', '/api/health'] 
    });
});

// Также оставляем другие пути для совместимости
app.get('/channels', (req, res) => {
    res.json({ success: true, channels });
});

app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'api' });
});

app.get('/', (req, res) => {
    res.json({ 
        message: 'API Server is RUNNING', 
        critical_endpoint: '/api/channels',
        timestamp: new Date().toISOString()
    });
});

// Запуск
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ FIXED API Server on port ${PORT}`);
    console.log(`📍 CRITICAL: http://localhost:${PORT}/api/channels`);
});
