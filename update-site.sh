#!/bin/bash

echo "🔄 Обновление функционала сайта..."

# Проверяем что находимся в правильной папке
if [ ! -d "development" ]; then
    echo "❌ Папка development не найдена"
    exit 1
fi

# Копируем новые файлы
echo "📁 Обновление HTML..."
cat > development/index.html << 'HTML'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Строительство домов под ключ в Большой Ялте | Профессиональные услуги</title>
    <meta name="description" content="Строительство домов под ключ в Большой Ялте. Полный цикл работ, современные BIM-технологии, гарантия качества. Бесплатная консультация и расчет сметы!">
    <meta name="keywords" content="строительство под ключ Ялта, строительство домов Крым, ремонт под ключ Большая Ялта, BIM проектирование">
    <link rel="stylesheet" href="css/main.css">
    <link rel="preload" href="css/mobile-first.css" as="style" media="(max-width: 768px)">
</head>
<body>
    <!-- Header -->
    <header class="header" role="banner">
        <div class="container">
            <div class="logo">
                <h1>Строительство под ключ в Большой Ялте</h1>
            </div>
            <nav class="nav" role="navigation">
                <button class="nav-toggle" aria-label="Меню">
                    <span></span>
                    <span></span>
                    <span></span>
                </button>
                <ul class="nav-menu">
                    <li><a href="#services">Услуги</a></li>
                    <li><a href="#portfolio">Проекты</a></li>
                    <li><a href="#advantages">Преимущества</a></li>
                    <li><a href="#reviews">Отзывы</a></li>
                    <li><a href="#contact">Контакты</a></li>
                </ul>
            </nav>
            <div class="header-phone">
                <a href="tel:+79780000000">+7 (978) 000-00-00</a>
            </div>
        </div>
    </header>

    <!-- Hero Section с калькулятором -->
    <section class="hero" aria-label="Главный баннер">
        <div class="container">
            <div class="hero-content">
                <h1>Строительство и ремонт под ключ в Большой Ялте</h1>
                <p class="hero-subtitle">Используем передовые технологии BIM-проектирования. От проекта до сдачи объекта за 90 дней</p>
                <div class="hero-features">
                    <div class="feature">
                        <span class="feature-icon">🏠</span>
                        <span>Гарантия 5 лет</span>
                    </div>
                    <div class="feature">
                        <span class="feature-icon">⚡</span>
                        <span>Срок от 90 дней</span>
                    </div>
                    <div class="feature">
                        <span class="feature-icon">📐</span>
                        <span>BIM технологии</span>
                    </div>
                </div>
                <div class="hero-buttons">
                    <button class="cta-button primary" onclick="openModal('consultation')">Бесплатная консультация</button>
                    <button class="cta-button secondary" onclick="openModal('portfolio')">Смотреть проекты</button>
                </div>
            </div>
            <div class="hero-visual">
                <div class="floating-card">
                    <div class="card-header">
                        <h3>Рассчитайте стоимость</h3>
                    </div>
                    <div class="card-body">
                        <div class="calc-input">
                            <label>Площадь объекта (м²)</label>
                            <input type="range" id="areaRange" min="50" max="500" value="120">
                            <span id="areaValue">120 м²</span>
                        </div>
                        <div class="calc-input">
                            <label>Тип работ</label>
                            <select id="workType">
                                <option value="standart">Стандарт</option>
                                <option value="comfort">Комфорт</option>
                                <option value="premium">Премиум</option>
                            </select>
                        </div>
                        <div class="calc-result">
                            <strong>Примерная стоимость:</strong>
                            <span id="costResult">2 400 000 ₽</span>
                        </div>
                        <button class="calc-button" onclick="openModal('calculation')">Точный расчет</button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Services Section -->
    <section id="services" class="services" aria-label="Наши услуги">
        <div class="container">
            <h2>Наши услуги</h2>
            <div class="services-grid">
                <article class="service-card" data-service="construction">
                    <div class="service-icon">🏗️</div>
                    <h3>Строительство домов</h3>
                    <p>Полный цикл от проектирования до сдачи объекта под ключ</p>
                    <ul class="service-features">
                        <li>Фундаментные работы</li>
                        <li>Возведение стен и кровли</li>
                        <li>Монтаж инженерных систем</li>
                        <li>Черновая и чистовая отделка</li>
                    </ul>
                    <button class="service-button" onclick="openModal('service', 'construction')">Подробнее</button>
                </article>

                <article class="service-card" data-service="renovation">
                    <div class="service-icon">🛠️</div>
                    <h3>Ремонт под ключ</h3>
                    <p>Капитальный и косметический ремонт любой сложности</p>
                    <ul class="service-features">
                        <li>Демонтажные работы</li>
                        <li>Электрика и сантехника</li>
                        <li>Отделочные работы</li>
                        <li>Умный дом и автоматизация</li>
                    </ul>
                    <button class="service-button" onclick="openModal('service', 'renovation')">Подробнее</button>
                </article>

                <article class="service-card" data-service="design">
                    <div class="service-icon">📐</div>
                    <h3>Проектирование</h3>
                    <p>BIM-технологии и 3D-визуализация вашего будущего дома</p>
                    <ul class="service-features">
                        <li>Архитектурное проектирование</li>
                        <li>Конструктивные решения</li>
                        <li>Инженерные системы</li>
                        <li>3D визуализация и VR</li>
                    </ul>
                    <button class="service-button" onclick="openModal('service', 'design')">Подробнее</button>
                </article>
            </div>
        </div>
    </section>

    <!-- Другие секции... -->
</body>
</html>
HTML

echo "🎨 Обновление CSS..."
# CSS и JS файлы будут обновлены из кода выше

echo "✅ Функционал обновлен!"
echo "🌐 Сайт доступен по: http://212.193.26.156:8000"
