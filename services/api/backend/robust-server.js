const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Mock data
const mockChannels = [
    { id: 1, name: 'Основной канал', status: 'active', users: 150 },
    { id: 2, name: 'Техническая поддержка', status: 'active', users: 45 },
    { id: 3, name: 'Новости', status: 'inactive', users: 0 }
];

// Routes
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        service: 'API Backend',
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

app.get('/api/channels', (req, res) => {
    res.json({
        success: true,
        data: mockChannels,
        total: mockChannels.length,
        timestamp: new Date().toISOString()
    });
});

app.get('/api/channels/:id', (req, res) => {
    const channel = mockChannels.find(c => c.id === parseInt(req.params.id));
    if (channel) {
        res.json({ success: true, data: channel });
    } else {
        res.status(404).json({ success: false, error: 'Channel not found' });
    }
});

app.post('/api/channels', (req, res) => {
    const newChannel = {
        id: mockChannels.length + 1,
        name: req.body.name || 'New Channel',
        status: 'active',
        users: 0
    };
    mockChannels.push(newChannel);
    res.json({ success: true, data: newChannel });
});

// Error handling
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
});

// Start server
app.listen(port, '0.0.0.0', () => {
    console.log(`✅ API server running on http://0.0.0.0:${port}`);
    console.log(`✅ Health check: http://localhost:${port}/api/health`);
    console.log(`✅ Channels: http://localhost:${port}/api/channels`);
});

process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});
