const express = require('express');
const app = express();
const PORT = 3003;

app.use(express.json());
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
    console.log(`  Headers:`, req.headers);
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', '*');
    res.header('Access-Control-Allow-Methods', '*');
    next();
});

const channels = [
    { id: 'telegram', name: 'Telegram', enabled: true, icon: '📱' },
    { id: 'vk', name: 'VKontakte', enabled: true, icon: '👥' },
    { id: 'email', name: 'Email', enabled: true, icon: '📧' }
];

app.get('/api/channels', (req, res) => {
    console.log('✅ Serving /api/channels');
    res.json({ success: true, channels });
});

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', service: 'api' });
});

app.get('/api/', (req, res) => {
    res.json({ message: 'API Root' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🐛 DEBUG API on port ${PORT}`);
});
