const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, '../frontend')));

// Инициализация БД
const db = new sqlite3.Database('/root/development/data/unit.db');

// Инициализация таблиц
function initializeDatabase() {
    db.serialize(() => {
        // Таблица услуг
        db.run(`CREATE TABLE IF NOT EXISTS services (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT,
            price INTEGER,
            duration TEXT,
            description TEXT,
            status TEXT DEFAULT 'active',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )`);

        // Таблица исполнителей
        db.run(`CREATE TABLE IF NOT EXISTS performers (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT,
            phone TEXT,
            skills TEXT,
            rating REAL DEFAULT 0,
            status TEXT DEFAULT 'available',
            hourly_rate INTEGER,
            experience TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )`);

        // Таблица назначений
        db.run(`CREATE TABLE IF NOT EXISTS assignments (
            id TEXT PRIMARY KEY,
            service_id TEXT,
            performer_id TEXT,
            status TEXT DEFAULT 'active',
            assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            completed_at DATETIME,
            FOREIGN KEY(service_id) REFERENCES services(id),
            FOREIGN KEY(performer_id) REFERENCES performers(id)
        )`);

        // Начальные данные
        const initServices = db.prepare("INSERT OR IGNORE INTO services (id, name, category, price, duration, description) VALUES (?, ?, ?, ?, ?, ?)");
        initServices.run('s1', 'Ремонт компьютеров', 'IT', 1500, '2 часа', 'Диагностика и ремонт компьютерной техники');
        initServices.run('s2', 'Уборка офиса', 'Клининг', 3000, '3 часа', 'Генеральная уборка офисных помещений');
        initServices.run('s3', 'Консультация юриста', 'Юридические', 2000, '1 час', 'Юридические консультации и документы');
        initServices.finalize();

        const initPerformers = db.prepare("INSERT OR IGNORE INTO performers (id, name, email, phone, skills, rating, hourly_rate) VALUES (?, ?, ?, ?, ?, ?, ?)");
        initPerformers.run('p1', 'Иван Петров', 'ivan@mail.com', '+79161234567', 'IT,Ремонт,Настройка', 4.8, 750);
        initPerformers.run('p2', 'Мария Сидорова', 'maria@mail.com', '+79161234568', 'Клининг,Уборка', 4.9, 1000);
        initPerformers.run('p3', 'Алексей Юристов', 'alex@mail.com', '+79161234569', 'Юридические,Консультации', 4.7, 2000);
        initPerformers.finalize();
    });
}

// API Routes
app.get('/api/services', (req, res) => {
    db.all("SELECT * FROM services WHERE status = 'active' ORDER BY created_at DESC", (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

app.post('/api/services', (req, res) => {
    const { name, category, price, duration, description } = req.body;
    const id = uuidv4();
    
    db.run("INSERT INTO services (id, name, category, price, duration, description) VALUES (?, ?, ?, ?, ?, ?)",
        [id, name, category, price, duration, description], 
        function(err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ id, message: 'Service created successfully' });
        });
});

app.get('/api/performers', (req, res) => {
    db.all("SELECT * FROM performers ORDER BY status, rating DESC", (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

app.post('/api/performers', (req, res) => {
    const { name, email, phone, skills, hourly_rate, experience } = req.body;
    const id = uuidv4();
    
    db.run("INSERT INTO performers (id, name, email, phone, skills, hourly_rate, experience) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [id, name, email, phone, skills, hourly_rate, experience], 
        function(err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ id, message: 'Performer created successfully' });
        });
});

app.get('/api/assignments', (req, res) => {
    db.all(`SELECT a.*, s.name as service_name, p.name as performer_name 
            FROM assignments a 
            LEFT JOIN services s ON a.service_id = s.id 
            LEFT JOIN performers p ON a.performer_id = p.id 
            ORDER BY a.assigned_at DESC`, (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

app.post('/api/assignments', (req, res) => {
    const { service_id, performer_id } = req.body;
    const id = uuidv4();
    
    db.run("INSERT INTO assignments (id, service_id, performer_id) VALUES (?, ?, ?)",
        [id, service_id, performer_id], 
        function(err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ id, message: 'Assignment created successfully' });
        });
});

app.get('/api/metrics', (req, res) => {
    const metrics = {};
    
    db.get("SELECT COUNT(*) as count FROM services WHERE status = 'active'", (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        metrics.services = row.count;
        
        db.get("SELECT COUNT(*) as count FROM performers", (err, row) => {
            if (err) return res.status(500).json({ error: err.message });
            metrics.performers = row.count;
            
            db.get("SELECT COUNT(*) as count FROM performers WHERE status = 'available'", (err, row) => {
                if (err) return res.status(500).json({ error: err.message });
                metrics.available = row.count;
                
                db.get("SELECT COUNT(*) as count FROM assignments WHERE status = 'active'", (err, row) => {
                    if (err) return res.status(500).json({ error: err.message });
                    metrics.activeAssignments = row.count;
                    
                    res.json(metrics);
                });
            });
        });
    });
});

// Инициализация БД при запуске
initializeDatabase();

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Unit Backend running on port ${PORT}`);
});
