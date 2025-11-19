const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// Mock data for channels
const mockChannels = [
    { id: 1, name: 'Основной канал', status: 'active', users: 150 },
    { id: 2, name: 'Техническая поддержка', status: 'active', users: 45 },
    { id: 3, name: 'Новости', status: 'inactive', users: 0 }
];

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Get channels endpoint
app.get('/api/channels', (req, res) => {
    res.json({
        success: true,
        data: mockChannels,
        total: mockChannels.length
    });
});

// Get channel by ID
app.get('/api/channels/:id', (req, res) => {
    const channel = mockChannels.find(c => c.id === parseInt(req.params.id));
    if (channel) {
        res.json({ success: true, data: channel });
    } else {
        res.status(404).json({ success: false, error: 'Channel not found' });
    }
});

// Create new channel
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

app.listen(port, () => {
    console.log(`API server running on port ${port}`);
});
