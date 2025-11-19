const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3003;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '..')));

// Simple in-memory storage
const channels = {
    telegram: { enabled: true, name: "Telegram", icon: "📱" },
    vk: { enabled: true, name: "VKontakte", icon: "👥" },
    email: { enabled: true, name: "Email", icon: "📧" }
};

let messageHistory = [];
let incomingData = [];

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        service: 'api-hub',
        timestamp: new Date().toISOString()
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({ 
        message: 'API Server is working!',
        endpoints: {
            health: '/health',
            channels: '/api/channels',
            messages: '/api/messages'
        }
    });
});

// Get channels
app.get('/api/channels', (req, res) => {
    res.json({ channels });
});

// Update channel
app.put('/api/channels/:channelId', (req, res) => {
    const { channelId } = req.params;
    const { enabled } = req.body;
    
    if (channels[channelId]) {
        channels[channelId].enabled = enabled;
        res.json({ success: true, channel: channels[channelId] });
    } else {
        res.status(404).json({ success: false, error: 'Channel not found' });
    }
});

// Get messages
app.get('/api/messages', (req, res) => {
    res.json({ messages: messageHistory });
});

// Add message
app.post('/api/messages', (req, res) => {
    const { text, channel } = req.body;
    const message = {
        id: Date.now(),
        text,
        channel,
        timestamp: new Date().toISOString()
    };
    messageHistory.push(message);
    res.json({ success: true, message });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ error: 'Internal Server Error' });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ API Server running on port ${PORT}`);
    console.log(`📍 Health: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('Shutting down gracefully...');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('Shutting down gracefully...');
    process.exit(0);
});
