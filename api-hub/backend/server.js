const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ extended: true }));

// Хранилище данных
let channels = {
    telegram: { 
        enabled: true, 
        name: "Telegram", 
        icon: "📱",
        config: { token: '', chats: [] }
    },
    vk: { 
        enabled: true, 
        name: "VKontakte", 
        icon: "👥",
        config: { token: '', group_id: '' }
    },
    email: { 
        enabled: true, 
        name: "Email", 
        icon: "📧",
        config: { smtp: {}, templates: [] }
    },
    whatsapp: { 
        enabled: false, 
        name: "WhatsApp", 
        icon: "💬",
        config: { token: '' }
    },
    sms: { 
        enabled: false, 
        name: "SMS", 
        icon: "📲",
        config: { provider: '' }
    }
};

let incomingData = [];
let messageHistory = [];

// 📤 API для распределения сообщений
app.post('/api/distribute', async (req, res) => {
    const { message, channels: targetChannels, settings = {} } = req.body;
    
    console.log(`📢 Распределение сообщения в каналы: ${targetChannels.join(', ')}`);
    
    const results = [];
    const messageId = generateId();
    
    for (const channel of targetChannels) {
        if (channels[channel] && channels[channel].enabled) {
            try {
                let result;
                switch (channel) {
                    case 'telegram':
                        result = await sendToTelegram(message, settings);
                        break;
                    case 'vk':
                        result = await sendToVK(message, settings);
                        break;
                    case 'email':
                        result = await sendToEmail(message, settings);
                        break;
                    case 'whatsapp':
                        result = await sendToWhatsApp(message, settings);
                        break;
                    case 'sms':
                        result = await sendToSMS(message, settings);
                        break;
                    default:
                        result = { error: `Unknown channel: ${channel}` };
                }
                
                results.push({ 
                    channel, 
                    status: result.error ? 'error' : 'success', 
                    result,
                    timestamp: new Date().toISOString()
                });
                
            } catch (error) {
                results.push({ 
                    channel, 
                    status: 'error', 
                    error: error.message,
                    timestamp: new Date().toISOString()
                });
            }
        } else {
            results.push({ 
                channel, 
                status: 'error', 
                error: `Channel ${channel} is disabled or not found`,
                timestamp: new Date().toISOString()
            });
        }
    }
    
    // Сохраняем в историю
    messageHistory.push({
        id: messageId,
        message,
        channels: targetChannels,
        results,
        timestamp: new Date().toISOString(),
        status: results.some(r => r.status === 'success') ? 'partial' : 'failed'
    });
    
    res.json({ 
        success: true, 
        messageId,
        results,
        timestamp: new Date().toISOString()
    });
});

// 📥 API для сбора данных
app.post('/api/collect', async (req, res) => {
    const { source, data, type = 'auto' } = req.body;
    
    console.log(`📥 Получены данные от источника: ${source}`);
    
    try {
        const processedData = await processIncomingData(data, source, type);
        const dataId = generateId();
        
        incomingData.push({
            id: dataId,
            source,
            data: processedData,
            type,
            timestamp: new Date().toISOString(),
            processed: true
        });
        
        res.json({ 
            success: true, 
            dataId,
            processed: processedData,
            timestamp: new Date().toISOString()
        });
        
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

// 📊 Получение всех данных
app.get('/api/data', (req, res) => {
    const { source, type, dateFrom, dateTo, limit = 100 } = req.query;
    
    let filteredData = [...incomingData];
    
    if (source) {
        filteredData = filteredData.filter(item => item.source === source);
    }
    
    if (type) {
        filteredData = filteredData.filter(item => item.type === type);
    }
    
    // Фильтрация по дате (базовая)
    if (dateFrom) {
        filteredData = filteredData.filter(item => item.timestamp >= dateFrom);
    }
    
    if (dateTo) {
        filteredData = filteredData.filter(item => item.timestamp <= dateTo);
    }
    
    // Сортировка по времени (новые сначала)
    filteredData.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
    
    res.json({ 
        data: filteredData.slice(0, parseInt(limit)),
        total: filteredData.length,
        returned: Math.min(filteredData.length, parseInt(limit))
    });
});

// 🎛️ Управление каналами
app.get('/api/channels', (req, res) => {
    res.json({ channels });
});

app.put('/api/channels/:channelId', (req, res) => {
    const { channelId } = req.params;
    const updates = req.body;
    
    if (channels[channelId]) {
        channels[channelId] = { ...channels[channelId], ...updates };
        res.json({ success: true, channel: channels[channelId] });
    } else {
        res.status(404).json({ success: false, error: 'Channel not found' });
    }
});

// 📈 Статистика
app.get('/api/stats', (req, res) => {
    const stats = {
        totalMessages: messageHistory.length,
        totalDataPoints: incomingData.length,
        channels: Object.keys(channels).reduce((acc, key) => {
            acc[key] = {
                enabled: channels[key].enabled,
                sent: messageHistory.filter(m => 
                    m.channels.includes(key) && 
                    m.results.find(r => r.channel === key && r.status === 'success')
                ).length
            };
            return acc;
        }, {}),
        sources: [...new Set(incomingData.map(item => item.source))],
        lastActivity: messageHistory.length > 0 ? 
            messageHistory[0].timestamp : null
    };
    
    res.json(stats);
});

// Функции для работы с каналами
async function sendToTelegram(message, settings) {
    // Заглушка для Telegram API
    console.log(`📱 Отправка в Telegram: ${message.substring(0, 50)}...`);
    await new Promise(resolve => setTimeout(resolve, 500)); // Имитация задержки
    
    return { 
        sent: true, 
        channel: 'telegram',
        message: 'Message queued for Telegram',
        timestamp: new Date().toISOString()
    };
}

async function sendToVK(message, settings) {
    // Заглушка для VK API
    console.log(`👥 Отправка в VK: ${message.substring(0, 50)}...`);
    await new Promise(resolve => setTimeout(resolve, 300));
    
    return { 
        sent: true, 
        channel: 'vk',
        message: 'Message posted to VK',
        timestamp: new Date().toISOString()
    };
}

async function sendToEmail(message, settings) {
    // Заглушка для Email
    console.log(`📧 Отправка по Email: ${message.substring(0, 50)}...`);
    await new Promise(resolve => setTimeout(resolve, 700));
    
    return { 
        sent: true, 
        channel: 'email',
        message: 'Email sent successfully',
        timestamp: new Date().toISOString()
    };
}

async function sendToWhatsApp(message, settings) {
    return { error: 'WhatsApp channel not configured' };
}

async function sendToSMS(message, settings) {
    return { error: 'SMS channel not configured' };
}

async function processIncomingData(data, source, type) {
    // Базовая обработка входящих данных
    return {
        raw: data,
        source,
        type,
        processed: true,
        processingDate: new Date().toISOString(),
        id: generateId(),
        metadata: {
            dataSize: JSON.stringify(data).length,
            fields: Object.keys(data),
            processedBy: 'api-hub-processor'
        }
    };
}

function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

// Запуск сервера
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 API Hub запущен на порту ${PORT}`);
    console.log(`📊 Endpoints:`);
    console.log(`   POST /api/distribute - Распределение сообщений`);
    console.log(`   POST /api/collect    - Сбор данных`);
    console.log(`   GET  /api/data       - Получение данных`);
    console.log(`   GET  /api/channels   - Управление каналами`);
    console.log(`   GET  /api/stats      - Статистика`);
});
