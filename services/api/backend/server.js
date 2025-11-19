const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3004;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Real GET endpoints for marketing channels
app.get('/api/channels', (req, res) => {
    const channels = [
        {
            id: 1,
            name: 'Google Ads',
            status: 'active',
            budget: 5000,
            conversions: 234,
            icon: '🔍'
        },
        {
            id: 2, 
            name: 'Facebook Ads',
            status: 'active',
            budget: 3500,
            conversions: 189,
            icon: '👥'
        },
        {
            id: 3,
            name: 'Email Marketing',
            status: 'active', 
            budget: 1200,
            conversions: 567,
            icon: '📧'
        },
        {
            id: 4,
            name: 'SEO',
            status: 'active',
            budget: 2000,
            conversions: 890,
            icon: '🚀'
        },
        {
            id: 5,
            name: 'Telegram',
            status: 'active',
            budget: 800,
            conversions: 345,
            icon: '📱'
        },
        {
            id: 6,
            name: 'VKontakte',
            status: 'active',
            budget: 1500,
            conversions: 278,
            icon: '👥'
        }
    ];
    res.json({ success: true, data: channels });
});

app.get('/api/landings', (req, res) => {
    const landings = [
        {
            id: 1,
            name: 'Main Landing Page',
            url: '/landing/main',
            conversions: 156,
            status: 'active',
            visitors: 1250
        },
        {
            id: 2,
            name: 'Product Catalog',
            url: '/landing/catalog', 
            conversions: 289,
            status: 'active',
            visitors: 2340
        },
        {
            id: 3,
            name: 'Special Offer',
            url: '/landing/special',
            conversions: 89,
            status: 'active', 
            visitors: 670
        }
    ];
    res.json({ success: true, data: landings });
});

app.get('/api/stats', (req, res) => {
    const stats = {
        totalVisitors: 12560,
        totalConversions: 2345,
        conversionRate: 18.7,
        revenue: 125000,
        activeChannels: 6,
        activeLandings: 3
    };
    res.json({ success: true, data: stats });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        service: 'API Gateway',
        version: '1.0.0'
    });
});

// Root endpoint
app.get('/api', (req, res) => {
    res.json({ 
        message: 'API Gateway is running!',
        endpoints: {
            channels: '/api/channels',
            landings: '/api/landings', 
            stats: '/api/stats',
            health: '/api/health'
        }
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log('='.repeat(50));
    console.log('🚀 API Gateway started on port', PORT);
    console.log('📍 Local: http://localhost:' + PORT + '/api');
    console.log('🌐 External: http://212.193.26.156:' + PORT + '/api');
    console.log('📊 CORS enabled for multiple origins');
    console.log('='.repeat(50));
});

// Root endpoint for API
app.get('/', (req, res) => {
    res.json({ 
        message: 'API Gateway is running!',
        endpoints: {
            health: '/api/health',
            channels: '/api/channels',
            landings: '/api/landings',
            stats: '/api/stats'
        }
    });
});
