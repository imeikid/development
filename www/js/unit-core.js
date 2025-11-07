class UnitPanel {
    constructor() {
        this.services = [];
        this.performers = [];
        this.assignments = [];
        this.currentView = 'connections';
        this.init();
    }

    async init() {
        console.log('🚀 Инициализация Unit-панели...');
        await this.loadData();
        this.renderAll();
        this.setupEventListeners();
        this.startAutoRefresh();
    }

    async loadData() {
        try {
            console.log('📥 Загрузка данных...');
            const [servicesRes, performersRes, assignmentsRes, metricsRes] = await Promise.all([
                fetch('/api/services').catch(err => { throw new Error('Ошибка загрузки услуг') }),
                fetch('/api/performers').catch(err => { throw new Error('Ошибка загрузки исполнителей') }),
                fetch('/api/assignments').catch(err => { throw new Error('Ошибка загрузки назначений') }),
                fetch('/api/metrics').catch(err => { throw new Error('Ошибка загрузки метрик') })
            ]);

            if (!servicesRes.ok) throw new Error('Сервер услуг недоступен');
            if (!performersRes.ok) throw new Error('Сервер исполнителей недоступен');
            if (!assignmentsRes.ok) throw new Error('Сервер назначений недоступен');
            if (!metricsRes.ok) throw new Error('Сервер метрик недоступен');

            this.services = await servicesRes.json();
            this.performers = await performersRes.json();
            this.assignments = await assignmentsRes.json();
            this.metrics = await metricsRes.json();

            console.log('✅ Данные загружены:', {
                services: this.services.length,
                performers: this.performers.length,
                assignments: this.assignments.length
            });

        } catch (error) {
            console.error('❌ Ошибка загрузки данных:', error);
            this.showError('Ошибка загрузки данных: ' + error.message);
            
            // Показываем демо-данные при ошибке
            this.loadDemoData();
        }
    }

    loadDemoData() {
        console.log('🔄 Загрузка демо-данных...');
        this.services = [
            { id: 's1', name: 'Ремонт компьютеров', category: 'IT', price: 1500, duration: '2 часа', status: 'active' },
            { id: 's2', name: 'Уборка офиса', category: 'Клининг', price: 3000, duration: '3 часа', status: 'active' },
            { id: 's3', name: 'Консультация юриста', category: 'Юридические', price: 2000, duration: '1 час', status: 'active' }
        ];

        this.performers = [
            { id: 'p1', name: 'Иван Петров', email: 'ivan@mail.com', phone: '+79161234567', skills: 'IT,Ремонт,Настройка', rating: 4.8, status: 'available', hourly_rate: 750 },
            { id: 'p2', name: 'Мария Сидорова', email: 'maria@mail.com', phone: '+79161234568', skills: 'Клининг,Уборка', rating: 4.9, status: 'available', hourly_rate: 1000 },
            { id: 'p3', name: 'Алексей Юристов', email: 'alex@mail.com', phone: '+79161234569', skills: 'Юридические,Консультации', rating: 4.7, status: 'busy', hourly_rate: 2000 }
        ];

        this.assignments = [
            { id: 'a1', service_id: 's1', performer_id: 'p1', status: 'active', service_name: 'Ремонт компьютеров', performer_name: 'Иван Петров' },
            { id: 'a2', service_id: 's2', performer_id: 'p2', status: 'completed', service_name: 'Уборка офиса', performer_name: 'Мария Сидорова' }
        ];

        this.metrics = {
            services: 3,
            performers: 3,
            available: 2,
            activeAssignments: 1
        };
    }

    renderAll() {
        this.renderServices();
        this.renderPerformers();
        this.renderManagement();
        this.updateMetrics();
    }

    renderServices() {
        const container = document.getElementById('services-list');
        if (!container) {
            console.error('❌ Контейнер услуг не найден');
            return;
        }

        if (this.services.length === 0) {
            container.innerHTML = '<div class="loading">Нет услуг для отображения</div>';
            return;
        }

        container.innerHTML = this.services.map(service => `
            <div class="item-card" data-service-id="${service.id}" 
                 ondragstart="unitApp.dragService(event)" draggable="true">
                <div class="item-header">
                    <strong>${this.escapeHtml(service.name)}</strong>
                    <span class="price-tag">${service.price}₽</span>
                </div>
                <div class="item-meta">
                    <span class="category">${this.escapeHtml(service.category)}</span>
                    <span class="duration">${this.escapeHtml(service.duration)}</span>
                </div>
                <div class="skills">
                    <span class="skill-tag">${this.escapeHtml(service.category)}</span>
                </div>
                <div class="item-actions">
                    <button onclick="unitApp.editService('${service.id}')" class="btn-sm">✏️</button>
                    <button onclick="unitApp.deleteService('${service.id}')" class="btn-sm">🗑️</button>
                </div>
            </div>
        `).join('');
        
        document.getElementById('services-count').textContent = this.services.length;
    }

    renderPerformers() {
        const container = document.getElementById('performers-list');
        if (!container) {
            console.error('❌ Контейнер исполнителей не найден');
            return;
        }

        if (this.performers.length === 0) {
            container.innerHTML = '<div class="loading">Нет исполнителей для отображения</div>';
            return;
        }

        container.innerHTML = this.performers.map(performer => `
            <div class="item-card" data-performer-id="${performer.id}"
                 ondragstart="unitApp.dragPerformer(event)" draggable="true">
                <div class="item-header">
                    <strong>${this.escapeHtml(performer.name)}</strong>
                    <span class="rating">⭐ ${performer.rating}</span>
                </div>
                <div class="item-meta">
                    <span class="email">${this.escapeHtml(performer.email || '')}</span>
                    <span class="rate">${performer.hourly_rate}₽/час</span>
                </div>
                <div class="skills">
                    ${performer.skills.split(',').map(skill => 
                        `<span class="skill-tag">${this.escapeHtml(skill.trim())}</span>`
                    ).join('')}
                </div>
                <div class="status ${performer.status}">
                    ${performer.status === 'available' ? '✅ Доступен' : '⏳ Занят'}
                </div>
            </div>
        `).join('');
        
        document.getElementById('performers-count').textContent = this.performers.length;
    }

    renderManagement() {
        const container = document.getElementById('management-area');
        if (!container) {
            console.error('❌ Контейнер управления не найден');
            return;
        }

        if (this.currentView === 'connections') {
            const activeAssignments = this.assignments.filter(a => a.status === 'active');
            
            container.innerHTML = `
                <div class="connections-view">
                    <h4>Активные связи (${activeAssignments.length})</h4>
                    <div class="connections-list">
                        ${activeAssignments.map(assignment => {
                            const service = this.services.find(s => s.id === assignment.service_id) || { name: assignment.service_name };
                            const performer = this.performers.find(p => p.id === assignment.performer_id) || { name: assignment.performer_name };
                            return `
                                <div class="connection-item item-card">
                                    <div class="connection-header">
                                        <span class="service">${this.escapeHtml(service.name)}</span>
                                        <span class="connector">↔</span>
                                        <span class="performer">${this.escapeHtml(performer.name)}</span>
                                    </div>
                                    <div class="connection-meta">
                                        <span class="status-badge ${assignment.status}">${assignment.status}</span>
                                        <span class="assigned-date">${new Date(assignment.assigned_at).toLocaleDateString('ru-RU')}</span>
                                    </div>
                                </div>
                            `;
                        }).join('')}
                    </div>
                    <div class="drop-zone" ondrop="unitApp.dropAssignment(event)" ondragover="unitApp.allowDrop(event)">
                        🎯 Перетащите услугу и исполнителя для создания связи
                    </div>
                </div>
            `;
        } else {
            container.innerHTML = `
                <div class="schedule-view">
                    <h4>Расписание исполнителей</h4>
                    <div class="schedule-grid">
                        ${this.performers.map(performer => `
                            <div class="schedule-item item-card">
                                <div class="item-header">
                                    <strong>${this.escapeHtml(performer.name)}</strong>
                                    <span class="status ${performer.status}">${performer.status === 'available' ? '✅' : '⏳'}</span>
                                </div>
                                <div class="schedule-slots">
                                    <div class="time-slot available">09:00-11:00</div>
                                    <div class="time-slot ${performer.status === 'available' ? 'available' : 'busy'}">11:00-13:00</div>
                                    <div class="time-slot available">14:00-16:00</div>
                                    <div class="time-slot available">16:00-18:00</div>
                                </div>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `;
        }
    }

    updateMetrics() {
        if (!this.metrics) return;

        const utilization = Math.round((this.metrics.activeAssignments / this.metrics.performers) * 100) || 0;
        const pending = Math.max(0, this.metrics.services - this.metrics.activeAssignments);

        document.getElementById('active-count').textContent = this.metrics.available;
        document.getElementById('metric-utilization').textContent = utilization + '%';
        document.getElementById('metric-pending').textContent = pending;
        document.getElementById('metric-completed').textContent = 
            this.assignments.filter(a => a.status === 'completed').length;
    }

    // Drag & Drop функционал
    allowDrop(ev) {
        ev.preventDefault();
    }

    dragService(ev) {
        ev.dataTransfer.setData("text/service", ev.target.dataset.serviceId);
        ev.target.style.opacity = '0.6';
    }

    dragPerformer(ev) {
        ev.dataTransfer.setData("text/performer", ev.target.dataset.performerId);
        ev.target.style.opacity = '0.6';
    }

    async dropAssignment(ev) {
        ev.preventDefault();
        const serviceId = ev.dataTransfer.getData("text/service");
        const performerId = ev.dataTransfer.getData("text/performer");
        
        // Восстанавливаем прозрачность перетаскиваемых элементов
        document.querySelectorAll('.item-card').forEach(card => {
            card.style.opacity = '1';
        });

        if (serviceId && performerId) {
            try {
                const service = this.services.find(s => s.id === serviceId);
                const performer = this.performers.find(p => p.id === performerId);

                if (!service || !performer) {
                    throw new Error('Услуга или исполнитель не найдены');
                }

                if (performer.status !== 'available') {
                    this.showError('Исполнитель недоступен для назначения');
                    return;
                }

                this.showNotification(`Создание связи: ${service.name} ↔ ${performer.name}`, 'success');

                // В демо-режиме просто добавляем локально
                const newAssignment = {
                    id: 'a' + Date.now(),
                    service_id: serviceId,
                    performer_id: performerId,
                    status: 'active',
                    service_name: service.name,
                    performer_name: performer.name,
                    assigned_at: new Date().toISOString()
                };

                this.assignments.push(newAssignment);
                this.renderManagement();
                this.updateMetrics();

            } catch (error) {
                console.error('❌ Ошибка создания связи:', error);
                this.showError('Ошибка создания связи: ' + error.message);
            }
        } else {
            this.showError('Перетащите как услугу, так и исполнителя');
        }
    }

    // Управление представлениями
    switchView(view) {
        this.currentView = view;
        this.renderManagement();
        
        // Обновляем активные кнопки
        document.querySelectorAll('.view-toggles .btn-sm').forEach(btn => {
            btn.classList.toggle('active', btn.textContent.toLowerCase().includes(view));
        });
    }

    // Формы добавления
    showAddServiceForm() {
        const modal = this.createModal(`
            <h3>➕ Добавить услугу</h3>
            <form onsubmit="event.preventDefault(); unitApp.handleAddService(event)">
                <input type="text" name="name" placeholder="Название услуги" required>
                <input type="text" name="category" placeholder="Категория" required>
                <input type="number" name="price" placeholder="Цена" required>
                <input type="text" name="duration" placeholder="Длительность" required>
                <textarea name="description" placeholder="Описание"></textarea>
                <div class="form-actions">
                    <button type="submit" class="btn-primary">Создать услугу</button>
                    <button type="button" onclick="unitApp.closeModal()" class="btn-sm">Отмена</button>
                </div>
            </form>
        `);
        document.getElementById('modals-container').appendChild(modal);
    }

    showAddPerformerForm() {
        const modal = this.createModal(`
            <h3>👥 Добавить исполнителя</h3>
            <form onsubmit="event.preventDefault(); unitApp.handleAddPerformer(event)">
                <input type="text" name="name" placeholder="ФИО" required>
                <input type="email" name="email" placeholder="Email">
                <input type="text" name="phone" placeholder="Телефон">
                <input type="text" name="skills" placeholder="Навыки (через запятую)" required>
                <input type="number" name="hourly_rate" placeholder="Ставка в час">
                <textarea name="experience" placeholder="Опыт работы"></textarea>
                <div class="form-actions">
                    <button type="submit" class="btn-primary">Добавить исполнителя</button>
                    <button type="button" onclick="unitApp.closeModal()" class="btn-sm">Отмена</button>
                </div>
            </form>
        `);
        document.getElementById('modals-container').appendChild(modal);
    }

    async handleAddService(event) {
        const formData = new FormData(event.target);
        const data = Object.fromEntries(formData);

        try {
            // В демо-режиме добавляем локально
            const newService = {
                id: 's' + Date.now(),
                name: data.name,
                category: data.category,
                price: parseInt(data.price),
                duration: data.duration,
                description: data.description,
                status: 'active',
                created_at: new Date().toISOString()
            };

            this.services.push(newService);
            this.renderServices();
            this.updateMetrics();
            this.closeModal();
            this.showSuccess('Услуга успешно добавлена!');

        } catch (error) {
            console.error('❌ Ошибка добавления услуги:', error);
            this.showError('Ошибка добавления услуги: ' + error.message);
        }
    }

    async handleAddPerformer(event) {
        const formData = new FormData(event.target);
        const data = Object.fromEntries(formData);

        try {
            // В демо-режиме добавляем локально
            const newPerformer = {
                id: 'p' + Date.now(),
                name: data.name,
                email: data.email,
                phone: data.phone,
                skills: data.skills,
                hourly_rate: parseInt(data.hourly_rate) || 0,
                experience: data.experience,
                rating: 4.5,
                status: 'available',
                created_at: new Date().toISOString()
            };

            this.performers.push(newPerformer);
            this.renderPerformers();
            this.updateMetrics();
            this.closeModal();
            this.showSuccess('Исполнитель успешно добавлен!');

        } catch (error) {
            console.error('❌ Ошибка добавления исполнителя:', error);
            this.showError('Ошибка добавления исполнителя: ' + error.message);
        }
    }

    // Вспомогательные методы
    createModal(content) {
        const modal = document.createElement('div');
        modal.className = 'modal-overlay';
        modal.innerHTML = `
            <div class="modal-content">
                ${content}
                <button class="modal-close" onclick="unitApp.closeModal()">×</button>
            </div>
        `;
        return modal;
    }

    closeModal() {
        const modal = document.querySelector('.modal-overlay');
        if (modal) modal.remove();
    }

    showSuccess(message) {
        this.showNotification(message, 'success');
    }

    showError(message) {
        this.showNotification(message, 'error');
    }

    showNotification(message, type) {
        // Удаляем старые уведомления
        document.querySelectorAll('.notification').forEach(n => n.remove());

        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        document.body.appendChild(notification);

        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 5000);
    }

    escapeHtml(unsafe) {
        if (!unsafe) return '';
        return unsafe
            .toString()
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    setupEventListeners() {
        // Глобальный поиск
        const searchInput = document.getElementById('global-search');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => {
                this.searchAll(e.target.value);
            });
        }

        // Перетаскивание
        document.addEventListener('dragover', this.allowDrop);
        document.addEventListener('dragend', () => {
            document.querySelectorAll('.item-card').forEach(card => {
                card.style.opacity = '1';
            });
        });
    }

    searchAll(query) {
        const searchTerm = query.toLowerCase().trim();
        
        if (!searchTerm) {
            // Показываем все элементы если поиск пустой
            document.querySelectorAll('.item-card').forEach(card => {
                card.style.display = 'block';
            });
            return;
        }

        // Фильтрация услуг
        this.services.forEach(service => {
            const card = document.querySelector(`[data-service-id="${service.id}"]`);
            if (card) {
                const matches = service.name.toLowerCase().includes(searchTerm) ||
                              service.category.toLowerCase().includes(searchTerm) ||
                              service.description?.toLowerCase().includes(searchTerm);
                card.style.display = matches ? 'block' : 'none';
            }
        });

        // Фильтрация исполнителей
        this.performers.forEach(performer => {
            const card = document.querySelector(`[data-performer-id="${performer.id}"]`);
            if (card) {
                const matches = performer.name.toLowerCase().includes(searchTerm) ||
                              performer.skills.toLowerCase().includes(searchTerm) ||
                              performer.email?.toLowerCase().includes(searchTerm);
                card.style.display = matches ? 'block' : 'none';
            }
        });
    }

    toggleAnalytics() {
        const content = document.getElementById('analytics-content');
        const icon = document.querySelector('.toggle-icon');
        
        if (content.style.display === 'none') {
            content.style.display = 'block';
            icon.textContent = '▼';
        } else {
            content.style.display = 'none';
            icon.textContent = '▲';
        }
    }

    startAutoRefresh() {
        // Автообновление данных каждые 30 секунд
        setInterval(async () => {
            await this.loadData();
            this.renderAll();
        }, 30000);
    }

    // Методы для демо-функциональности
    editService(id) {
        const service = this.services.find(s => s.id === id);
        if (service) {
            this.showNotification(`Редактирование: ${service.name}`, 'success');
        }
    }

    deleteService(id) {
        const service = this.services.find(s => s.id === id);
        if (service && confirm(`Удалить услугу "${service.name}"?`)) {
            this.services = this.services.filter(s => s.id !== id);
            this.renderServices();
            this.updateMetrics();
            this.showSuccess('Услуга удалена');
        }
    }
}

// Глобальная инициализация
let unitApp;

document.addEventListener('DOMContentLoaded', () => {
    console.log('📄 DOM загружен, инициализация UnitPanel...');
    unitApp = new UnitPanel();
});

// Глобальные функции для onclick атрибутов
function toggleAnalytics() {
    if (unitApp) unitApp.toggleAnalytics();
}

function searchAll() {
    if (unitApp) unitApp.searchAll(document.getElementById('global-search').value);
}
