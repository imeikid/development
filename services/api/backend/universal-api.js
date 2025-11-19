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

// ВСЕ возможные эндпоинты для каналов
app.get('/api/channels', (req, res) => {
    res.json({ success: true, channels });
});

app.get('/channels', (req, res) => {
    res.json({ success: true, channels });
});

app.get('/v1/channels', (req, res) => {
    res.json({ success: true, channels });
});

app.get('/v2/channels', (req, res) => {
    res.json({ success: true, channels });
});

app.get('/data/channels', (req, res) => {
    res.json({ success: true, channels });
});

// Health checks
app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'api' });
});

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', service: 'api' });
});

app.get('/', (req, res) => {
    res.json({ 
        message: 'API Server', 
        endpoints: ['/api/channels', '/channels', '/health'] 
    });
});

// Запуск
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Universal API on port ${PORT}`);
});
