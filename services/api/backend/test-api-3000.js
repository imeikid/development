const express = require('express');
const app = express();
const PORT = 3000;

app.use(express.json());
app.use((req, res, next) => {
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
    console.log('API: Serving channels');
    res.json({ success: true, channels });
});

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Test API on port ${PORT}`);
});
