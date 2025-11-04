#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="development"

echo -e "${GREEN}Создаем структуру проекта...${NC}"

# Создаем папки
mkdir -p $PROJECT_DIR/{css,js,images,assets,seo}

# Создаем index.html
cat > $PROJECT_DIR/index.html << 'HTML'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Строительство домов под ключ в Большой Ялте</title>
    <meta name="description" content="Строительство домов под ключ в Большой Ялте. Полный цикл работ, современные технологии, гарантия качества.">
    <link rel="stylesheet" href="css/main.css">
</head>
<body>
    <header>
        <div class="container">
            <h1>Строительство под ключ в Большой Ялте</h1>
        </div>
    </header>
    
    <main>
        <section class="hero">
            <div class="container">
                <h2>Строительство и ремонт под ключ</h2>
                <p>Используем передовые технологии BIM-проектирования</p>
                <button class="cta-button">Бесплатная консультация</button>
            </div>
        </section>
        
        <section class="services">
            <div class="container">
                <h2>Наши услуги</h2>
                <div class="services-grid">
                    <div class="service-card">
                        <h3>🏠 Строительство домов</h3>
                        <p>Полный цикл от проекта до сдачи</p>
                    </div>
                    <div class="service-card">
                        <h3>🛠️ Ремонт под ключ</h3>
                        <p>Капитальный и косметический ремонт</p>
                    </div>
                </div>
            </div>
        </section>
    </main>
    
    <script src="js/main.js"></script>
</body>
</html>
HTML

# Создаем main.css
cat > $PROJECT_DIR/css/main.css << 'CSS'
:root {
    --primary: #2c5530;
    --accent: #d4af37;
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 1rem;
}

header {
    background: var(--primary);
    color: white;
    padding: 1rem 0;
    position: fixed;
    width: 100%;
    top: 0;
}

.hero {
    margin-top: 80px;
    padding: 4rem 1rem;
    background: linear-gradient(135deg, var(--primary), #1e3a23);
    color: white;
    text-align: center;
}

.cta-button {
    background: var(--accent);
    color: white;
    padding: 1rem 2rem;
    border: none;
    border-radius: 50px;
    font-size: 1.2rem;
    margin-top: 2rem;
    cursor: pointer;
}

.services {
    padding: 4rem 1rem;
}

.services-grid {
    display: grid;
    gap: 2rem;
    margin-top: 2rem;
}

.service-card {
    background: white;
    padding: 2rem;
    border-radius: 10px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

@media (max-width: 768px) {
    .hero h2 {
        font-size: 1.8rem;
    }
    
    .cta-button {
        min-height: 44px;
        min-width: 44px;
    }
    
    .services-grid {
        grid-template-columns: 1fr;
    }
}

@media (min-width: 769px) {
    .services-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}
CSS

# Создаем JavaScript
cat > $PROJECT_DIR/js/main.js << 'JS'
document.addEventListener('DOMContentLoaded', function() {
    console.log('Сайт строительства в Ялте загружен');
    
    // Обработчик для кнопки
    const ctaButton = document.querySelector('.cta-button');
    if (ctaButton) {
        ctaButton.addEventListener('click', function() {
            alert('Спасибо за интерес! Свяжемся с вами в течение 15 минут.');
        });
    }
});
JS

# Создаем robots.txt
cat > $PROJECT_DIR/robots.txt << 'ROBOTS'
User-agent: *
Allow: /
Sitemap: https://ваш-сайт.ru/sitemap.xml
ROBOTS

# Создаем .htaccess
cat > $PROJECT_DIR/.htaccess << 'HTACCESS'
RewriteEngine On

# Mobile detection
RewriteCond %{HTTP_USER_AGENT} "android|blackberry|iphone" [NC]
RewriteRule ^$ / [L]

# Gzip compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/css application/javascript
</IfModule>
HTACCESS

echo -e "${GREEN}Проект успешно создан в папке $PROJECT_DIR/${NC}"
echo -e "${YELLOW}Для просмотра откройте файл: $PROJECT_DIR/index.html${NC}"
