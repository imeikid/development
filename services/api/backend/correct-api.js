const http = require('http');

const mockChannels = [
    { id: 1, name: 'Основной канал', status: 'active', users: 150 },
    { id: 2, name: 'Техническая поддержка', status: 'active', users: 45 },
    { id: 3, name: 'Новости', status: 'inactive', users: 0 }
];

const server = http.createServer((req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }
    
    // API routes with /api prefix
    if (req.url === '/api/health' && req.method === 'GET') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            status: 'OK',
            service: 'API Backend',
            timestamp: new Date().toISOString(),
            version: '1.0.0'
        }));
    }
    else if (req.url === '/api/channels' && req.method === 'GET') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            success: true,
            data: mockChannels,
            total: mockChannels.length,
            timestamp: new Date().toISOString()
        }));
    }
    else if (req.url === '/api/channels' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            try {
                const data = JSON.parse(body);
                const newChannel = {
                    id: mockChannels.length + 1,
                    name: data.name || 'New Channel',
                    status: 'active',
                    users: 0
                };
                mockChannels.push(newChannel);
                
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    success: true,
                    data: newChannel
                }));
            } catch (e) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    success: false,
                    error: 'Invalid JSON'
                }));
            }
        });
    }
    else {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            error: 'Not Found',
            message: `Cannot ${req.method} ${req.url}`
        }));
    }
});

server.listen(3000, '0.0.0.0', () => {
    console.log('Correct API server running on port 3000');
    console.log('Endpoints:');
    console.log('  GET  /api/health');
    console.log('  GET  /api/channels');
    console.log('  POST /api/channels');
});
