const express = require('express');
const app = express();
const PORT = 3003;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', '*');
    res.header('Access-Control-Allow-Methods', '*');
    next();
});

// Routes - максимально простые
app.get('/', (req, res) => {
    console.log('GET /');
    res.json({ 
        message: 'API Server is RUNNING!',
        timestamp: new Date().toISOString(),
        status: 'OK'
    });
});

app.get('/health', (req, res) => {
    console.log('GET /health');
    res.json({ 
        status: 'healthy', 
        service: 'api',
        timestamp: new Date().toISOString()
    });
});

app.get('/api/health', (req, res) => {
    console.log('GET /api/health');
    res.json({ 
        status: 'healthy', 
        service: 'api',
        timestamp: new Date().toISOString()
    });
});

app.get('/test', (req, res) => {
    console.log('GET /test');
    res.json({ message: 'Test endpoint works!', success: true });
});

// 404 handler
app.use((req, res) => {
    console.log('404 for:', req.url);
    res.status(404).json({ error: 'Not found', path: req.url });
});

// Error handler - без process.exit!
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ error: 'Something went wrong' });
});

// Start server
console.log('Starting ultra-stable API server...');
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 ULTRA-STABLE API Server running on port ${PORT}`);
    console.log(`📍 Test: curl http://localhost:${PORT}/health`);
});

// Без process.exit вообще!
