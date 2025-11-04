// Main application functionality
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    // Initialize all components
    initNavigation();
    initCalculator();
    initPortfolioFilter();
    initScrollAnimations();
    initModalSystem();
    
    console.log('🚀 Строительство под ключ в Большой Ялте - сайт загружен');
}

// Navigation functionality
function initNavigation() {
    const navToggle = document.querySelector('.nav-toggle');
    const navMenu = document.querySelector('.nav-menu');
    const header = document.querySelector('.header');
    
    // Mobile menu toggle
    if (navToggle) {
        navToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');
            this.classList.toggle('active');
        });
    }
    
    // Header scroll effect
    window.addEventListener('scroll', function() {
        if (window.scrollY > 100) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
    });
    
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
                
                // Close mobile menu if open
                if (navMenu.classList.contains('active')) {
                    navMenu.classList.remove('active');
                    navToggle.classList.remove('active');
                }
            }
        });
    });
}

// Cost calculator functionality
function initCalculator() {
    const areaRange = document.getElementById('areaRange');
    const areaValue = document.getElementById('areaValue');
    const workType = document.getElementById('workType');
    const costResult = document.getElementById('costResult');
    
    if (!areaRange) return;
    
    const pricePerMeter = {
        'standart': 20000,
        'comfort': 25000,
        'premium': 35000
    };
    
    function updateCalculation() {
        const area = parseInt(areaRange.value);
        const type = workType.value;
        const cost = area * pricePerMeter[type];
        
        areaValue.textContent = `${area} м²`;
        costResult.textContent = `${cost.toLocaleString('ru-RU')} ₽`;
    }
    
    areaRange.addEventListener('input', updateCalculation);
    workType.addEventListener('change', updateCalculation);
    
    // Initial calculation
    updateCalculation();
}

// Portfolio filter functionality
function initPortfolioFilter() {
    const filterBtns = document.querySelectorAll('.filter-btn');
    const portfolioItems = document.querySelectorAll('.portfolio-item');
    
    filterBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            // Remove active class from all buttons
            filterBtns.forEach(b => b.classList.remove('active'));
            
            // Add active class to clicked button
            this.classList.add('active');
            
            const filter = this.getAttribute('data-filter');
            
            // Filter portfolio items
            portfolioItems.forEach(item => {
                if (filter === 'all' || item.getAttribute('data-category') === filter) {
                    item.style.display = 'block';
                    setTimeout(() => {
                        item.style.opacity = '1';
                        item.style.transform = 'scale(1)';
                    }, 100);
                } else {
                    item.style.opacity = '0';
                    item.style.transform = 'scale(0.8)';
                    setTimeout(() => {
                        item.style.display = 'none';
                    }, 300);
                }
            });
        });
    });
}

// Scroll animations
function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
            }
        });
    }, observerOptions);
    
    // Observe elements for animation
    document.querySelectorAll('.service-card, .advantage-card, .portfolio-item').forEach(el => {
        observer.observe(el);
    });
}

// Modal system
function initModalSystem() {
    const modal = document.getElementById('modal');
    const modalBody = document.getElementById('modal-body');
    
    // Close modal on backdrop click
    modal.addEventListener('click', function(e) {
        if (e.target === modal) {
            closeModal();
        }
    });
    
    // Close modal on Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeModal();
        }
    });
}

// Modal functions
function openModal(type, data = null) {
    const modal = document.getElementById('modal');
    const modalBody = document.getElementById('modal-body');
    
    let content = '';
    
    switch(type) {
        case 'consultation':
            content = getConsultationForm();
            break;
        case 'callback':
            content = getCallbackForm();
            break;
        case 'portfolio':
            content = getPortfolioContent();
            break;
        case 'calculation':
            content = getCalculationForm();
            break;
        case 'service':
            content = getServiceContent(data);
            break;
        default:
            content = getConsultationForm();
    }
    
    modalBody.innerHTML = content;
    modal.style.display = 'block';
    document.body.style.overflow = 'hidden';
}

function closeModal() {
    const modal = document.getElementById('modal');
    modal.style.display = 'none';
    document.body.style.overflow = 'auto';
}

// Modal content templates
function getConsultationForm() {
    return `
        <h2>Бесплатная консультация</h2>
        <p>Оставьте заявку и мы свяжемся с вами в течение 15 минут</p>
        <form class="modal-form" onsubmit="handleFormSubmit(event, 'consultation')">
            <div class="form-group">
                <input type="text" name="name" placeholder="Ваше имя" required>
            </div>
            <div class="form-group">
                <input type="tel" name="phone" placeholder="Телефон" required>
            </div>
            <div class="form-group">
                <textarea name="message" placeholder="Опишите ваш проект" rows="4"></textarea>
            </div>
            <button type="submit" class="cta-button primary">Получить консультацию</button>
        </form>
    `;
}

function getCallbackForm() {
    return `
        <h2>Заказать звонок</h2>
        <p>Мы перезвоним вам в удобное время</p>
        <form class="modal-form" onsubmit="handleFormSubmit(event, 'callback')">
            <div class="form-group">
                <input type="text" name="name" placeholder="Ваше имя" required>
            </div>
            <div class="form-group">
                <input type="tel" name="phone" placeholder="Телефон" required>
            </div>
            <div class="form-group">
                <select name="time">
                    <option value="">Удобное время для звонка</option>
                    <option value="9-12">9:00 - 12:00</option>
                    <option value="12-15">12:00 - 15:00</option>
                    <option value="15-18">15:00 - 18:00</option>
                    <option value="18-20">18:00 - 20:00</option>
                </select>
            </div>
            <button type="submit" class="cta-button primary">Заказать звонок</button>
        </form>
    `;
}

function getCalculationForm() {
    return `
        <h2>Точный расчет стоимости</h2>
        <p>Получите детализированную смету для вашего проекта</p>
        <form class="modal-form" onsubmit="handleFormSubmit(event, 'calculation')">
            <div class="form-group">
                <input type="text" name="name" placeholder="Ваше имя" required>
            </div>
            <div class="form-group">
                <input type="tel" name="phone" placeholder="Телефон" required>
            </div>
            <div class="form-group">
                <input type="email" name="email" placeholder="Email для сметы">
            </div>
            <div class="form-group">
                <select name="project_type" required>
                    <option value="">Тип проекта</option>
                    <option value="house">Частный дом</option>
                    <option value="apartment">Квартира</option>
                    <option value="commercial">Коммерческий объект</option>
                </select>
            </div>
            <div class="form-group">
                <input type="number" name="area" placeholder="Площадь (м²)" required>
            </div>
            <button type="submit" class="cta-button primary">Получить расчет</button>
        </form>
    `;
}

function getServiceContent(serviceType) {
    const services = {
        'construction': {
            title: 'Строительство домов',
            description: 'Полный цикл строительных работ от проекта до сдачи объекта'
        },
        'renovation': {
            title: 'Ремонт под ключ',
            description: 'Капитальный и косметический ремонт любой сложности'
        },
        'design': {
            title: 'Проектирование',
            description: 'BIM-технологии и 3D-визуализация'
        }
    };
    
    const service = services[serviceType] || services.construction;
    
    return `
        <h2>${service.title}</h2>
        <p>${service.description}</p>
        <div class="service-details">
            <h3>Этапы работы:</h3>
            <ul>
                <li>Консультация и замеры</li>
                <li>Разработка проекта</li>
                <li>Согласование сметы</li>
                <li>Выполнение работ</li>
                <li>Сдача объекта</li>
                <li>Гарантийное обслуживание</li>
            </ul>
        </div>
        <button class="cta-button primary" onclick="openModal('consultation')">Обсудить проект</button>
    `;
}

// Form handling
function handleFormSubmit(event, formType) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const data = Object.fromEntries(formData);
    
    // Here you would typically send data to your server
    console.log('Form submitted:', formType, data);
    
    // Show success message
    alert('Спасибо! Ваша заявка принята. Мы свяжемся с вами в течение 15 минут.');
    closeModal();
    event.target.reset();
    
    // Simulate sending to analytics
    trackConversion(formType);
}

function trackConversion(type) {
    // Simulate analytics tracking
    console.log(`Conversion tracked: ${type}`);
}

// Utility functions
function formatPhone(phone) {
    return phone.replace(/\D/g, '').replace(/^7/, '8');
}

// Initialize when DOM is loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeApp);
} else {
    initializeApp();
}
