const express = require('express');
const app = express();
const PORT = 3003;

app.use(express.json());

// Enable CORS
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', '*');
    res.header('Access-Control-Allow-Methods', '*');
    next();
});

// Test endpoint at root
app.get('/', (req, res) => {
    res.json({ 
        message: 'API Server Root',
        endpoints: ['/health', '/api/health', '/test']
    });
});

// Health at multiple endpoints
app.get('/health', (req, res) => {
    res.json({ status: 'OK', service: 'api', timestamp: new Date().toISOString() });
});

app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', service: 'api', timestamp: new Date().toISOString() });
});

app.get('/test', (req, res) => {
    res.json({ message: 'Test endpoint works!' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Simple API Server running on port ${PORT}`);
    console.log(`📍 Test: curl http://localhost:${PORT}/health`);
});

process.on('SIGTERM', () => process.exit(0));
