const express = require('express');
const app = express();
const PORT = 3003;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    next();
});

// Mock data for channels
const channelsData = {
    telegram: { 
        id: 'telegram', 
        name: 'Telegram', 
        enabled: true, 
        icon: '📱',
        description: 'Telegram messenger integration'
    },
    vk: { 
        id: 'vk', 
        name: 'VKontakte', 
        enabled: true, 
        icon: '👥',
        description: 'VK social network integration'
    },
    email: { 
        id: 'email', 
        name: 'Email', 
        enabled: false, 
        icon: '📧',
        description: 'Email marketing channel'
    },
    whatsapp: { 
        id: 'whatsapp', 
        name: 'WhatsApp', 
        enabled: true, 
        icon: '💬',
        description: 'WhatsApp Business API'
    }
};

const messagesData = [
    { id: 1, text: 'Welcome message', channel: 'telegram', timestamp: new Date().toISOString() },
    { id: 2, text: 'Promotion', channel: 'vk', timestamp: new Date().toISOString() }
];

// Routes
app.get('/', (req, res) => {
    res.json({ 
        message: 'CRM API Server is RUNNING!',
        timestamp: new Date().toISOString(),
        version: '1.0',
        endpoints: ['/health', '/api/channels', '/api/messages', '/api/health']
    });
});

app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        service: 'crm-api',
        timestamp: new Date().toISOString()
    });
});

app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        service: 'crm-api',
        timestamp: new Date().toISOString()
    });
});

// Критически важные эндпоинты для фронтенда
app.get('/api/channels', (req, res) => {
    console.log('GET /api/channels');
    const channels = Object.values(channelsData);
    res.json({ 
        success: true,
        channels: channels,
        count: channels.length
    });
});

app.get('/api/channels/:id', (req, res) => {
    const channelId = req.params.id;
    const channel = channelsData[channelId];
    
    if (channel) {
        res.json({ success: true, channel });
    } else {
        res.status(404).json({ success: false, error: 'Channel not found' });
    }
});

app.put('/api/channels/:id', (req, res) => {
    const channelId = req.params.id;
    const { enabled } = req.body;
    
    if (channelsData[channelId]) {
        channelsData[channelId].enabled = enabled;
        res.json({ success: true, channel: channelsData[channelId] });
    } else {
        res.status(404).json({ success: false, error: 'Channel not found' });
    }
});

app.get('/api/messages', (req, res) => {
    res.json({ 
        success: true,
        messages: messagesData,
        count: messagesData.length
    });
});

app.post('/api/messages', (req, res) => {
    const { text, channel } = req.body;
    const newMessage = {
        id: messagesData.length + 1,
        text,
        channel,
        timestamp: new Date().toISOString()
    };
    messagesData.push(newMessage);
    res.json({ success: true, message: newMessage });
});

// 404 handler
app.use((req, res) => {
    console.log('404 for:', req.method, req.url);
    res.status(404).json({ error: 'Endpoint not found', path: req.url });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(500).json({ error: 'Internal server error' });
});

// Start server
console.log('Starting complete CRM API server...');
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 CRM API Server running on port ${PORT}`);
    console.log(`📍 Health: http://localhost:${PORT}/health`);
    console.log(`📍 Channels: http://localhost:${PORT}/api/channels`);
});
