class IOSUnitPanel {
    constructor() {
        this.services = [];
        this.performers = [];
        this.assignments = [];
        this.groupedServices = {};
        this.groupedPerformers = {};
        this.init();
    }

    async init() {
        console.log('🚀 Инициализация iOS Unit-панели...');
        await this.loadData();
        this.renderAll();
        this.setupEventListeners();
    }

    async loadData() {
        try {
            const [servicesRes, performersRes] = await Promise.all([
                fetch('/api/services'),
                fetch('/api/performers')
            ]);

            this.services = await servicesRes.json();
            this.performers = await performersRes.json();
            this.groupData();
        } catch (error) {
            console.error('Ошибка загрузки данных:', error);
            this.loadDemoData();
        }
    }

    groupData() {
        this.groupedServices = {};
        this.services.forEach(service => {
            if (!this.groupedServices[service.category]) {
                this.groupedServices[service.category] = [];
            }
            this.groupedServices[service.category].push(service);
        });

        this.groupedPerformers = {};
        this.performers.forEach(performer => {
            const firstSkill = performer.skills.split(',')[0].trim();
            if (!this.groupedPerformers[firstSkill]) {
                this.groupedPerformers[firstSkill] = [];
            }
            this.groupedPerformers[firstSkill].push(performer);
        });
    }

    renderAll() {
        this.renderServices();
        this.renderPerformers();
        this.updateCounts();
    }

    renderServices() {
        const container = document.getElementById('services-stack');
        if (!container) return;

        let html = '';
        Object.entries(this.groupedServices).forEach(([category, services]) => {
            html += `
                <div class="stack-group">
                    <div class="group-header" onclick="unitApp.toggleGroup('services-${category}')">
                        <div class="group-title">${category}</div>
                        <div class="group-count">${services.length} услуг</div>
                    </div>
                    <div class="group-content" id="services-${category}">
                        ${services.map(service => `
                            <div class="ios-card" data-service-id="${service.id}">
                                <div class="card-header">
                                    <div class="card-title">${this.escapeHtml(service.name)}</div>
                                    <div class="card-price">${service.price}₽</div>
                                </div>
                                <div class="card-meta">
                                    <span>${service.duration}</span>
                                    <span>•</span>
                                    <span>${service.category}</span>
                                </div>
                                <div class="card-actions">
                                    <button class="btn-ios btn-primary" onclick="unitApp.assignService('${service.id}')">Назначить</button>
                                    <button class="btn-ios btn-secondary" onclick="unitApp.editService('${service.id}')">Изменить</button>
                                </div>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `;
        });
        container.innerHTML = html;
    }
    renderPerformers() {
        const container = document.getElementById('performers-stack');
        if (!container) return;

        let html = '';
        Object.entries(this.groupedPerformers).forEach(([skill, performers]) => {
            html += `
                <div class="stack-group">
                    <div class="group-header" onclick="unitApp.toggleGroup('performers-${skill}')">
                        <div class="group-title">${skill}</div>
                        <div class="group-count">${performers.length} чел.</div>
                    </div>
                    <div class="group-content" id="performers-${skill}">
                        ${performers.map(performer => `
                            <div class="ios-card" data-performer-id="${performer.id}">
                                <div class="card-header">
                                    <div class="card-title">${this.escapeHtml(performer.name)}</div>
                                    <div class="card-rating">⭐ ${performer.rating}</div>
                                </div>
                                <div class="card-meta">
                                    <span>${performer.email}</span>
                                    <span>•</span>
                                    <span>${performer.hourly_rate}₽/час</span>
                                </div>
                                <div class="skills">
                                    ${performer.skills.split(',').map(skill => 
                                        `<span class="skill-tag">${skill.trim()}</span>`
                                    ).join('')}
                                </div>
                                <div class="card-actions">
                                    <button class="btn-ios btn-primary" onclick="unitApp.viewPerformer('${performer.id}')">Профиль</button>
                                    <button class="btn-ios btn-secondary" onclick="unitApp.assignPerformer('${performer.id}')">Назначить</button>
                                </div>
                            </div>
                        `).join('')}
                    </div>
                </div>
            `;
        });
        container.innerHTML = html;
    }

    updateCounts() {
        const servicesCount = document.getElementById('services-count');
        const performersCount = document.getElementById('performers-count');
        if (servicesCount) servicesCount.textContent = this.services.length;
        if (performersCount) performersCount.textContent = this.performers.length;
    }

    toggleGroup(groupId) {
        const group = document.getElementById(groupId);
        if (group) group.classList.toggle('expanded');
    }

    showAddServiceForm() {
        const modal = this.createModal(`
            <div class="modal-header">
                <h2 class="modal-title">Новая услуга</h2>
                <button class="close-btn" onclick="unitApp.closeModal()">×</button>
            </div>
            <form class="ios-form" onsubmit="event.preventDefault(); unitApp.handleAddService(event)">
                <div class="form-group">
                    <label class="form-label">Название услуги</label>
                    <input type="text" class="form-input" name="name" placeholder="Ремонт компьютера" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Категория</label>
                    <input type="text" class="form-input" name="category" placeholder="IT" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Цена</label>
                    <input type="number" class="form-input" name="price" placeholder="1000" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Длительность</label>
                    <input type="text" class="form-input" name="duration" placeholder="2 часа" required>
                </div>
                <button type="submit" class="btn-ios btn-primary" style="width: 100%; margin-top: 16px;">Создать услугу</button>
            </form>
        `);
        document.getElementById('modals-container').appendChild(modal);
    }
    showAddPerformerForm() {
        const modal = this.createModal(`
            <div class="modal-header">
                <h2 class="modal-title">Новый исполнитель</h2>
                <button class="close-btn" onclick="unitApp.closeModal()">×</button>
            </div>
            <form class="ios-form" onsubmit="event.preventDefault(); unitApp.handleAddPerformer(event)">
                <div class="form-group">
                    <label class="form-label">ФИО</label>
                    <input type="text" class="form-input" name="name" placeholder="Иван Петров" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-input" name="email" placeholder="ivan@mail.com">
                </div>
                <div class="form-group">
                    <label class="form-label">Телефон</label>
                    <input type="tel" class="form-input" name="phone" placeholder="+79161234567">
                </div>
                <div class="form-group">
                    <label class="form-label">Навыки</label>
                    <input type="text" class="form-input" name="skills" placeholder="IT, Ремонт, Настройка" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Ставка в час</label>
                    <input type="number" class="form-input" name="hourly_rate" placeholder="1000">
                </div>
                <button type="submit" class="btn-ios btn-primary" style="width: 100%; margin-top: 16px;">Добавить исполнителя</button>
            </form>
        `);
        document.getElementById('modals-container').appendChild(modal);
    }

    createModal(content) {
        const modal = document.createElement('div');
        modal.className = 'ios-modal';
        modal.innerHTML = `<div class="modal-content">${content}</div>`;
        modal.addEventListener('click', (e) => {
            if (e.target === modal) this.closeModal();
        });
        return modal;
    }

    closeModal() {
        const modal = document.querySelector('.ios-modal');
        if (modal) modal.remove();
    }

    loadDemoData() {
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
        this.groupData();
    }

    escapeHtml(unsafe) {
        return unsafe.toString()
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    setupEventListeners() {
        const searchInput = document.querySelector('.ios-search');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => {
                this.searchAll(e.target.value);
            });
        }
    }

    searchAll(query) {
        console.log('Поиск:', query);
    }

    assignService(serviceId) {
        alert('Назначение услуги: ' + serviceId);
    }

    assignPerformer(performerId) {
        alert('Назначение исполнителя: ' + performerId);
    }

    editService(serviceId) {
        alert('Редактирование услуги: ' + serviceId);
    }

    viewPerformer(performerId) {
        alert('Просмотр исполнителя: ' + performerId);
    }

    showAssignments() {
        alert('Раздел назначений');
    }

    showAnalytics() {
        alert('Аналитика и отчеты');
    }

    async handleAddService(event) {
        const formData = new FormData(event.target);
        const data = Object.fromEntries(formData);
        console.log('Добавление услуги:', data);
        alert('Услуга добавлена!');
        this.closeModal();
    }

    async handleAddPerformer(event) {
        const formData = new FormData(event.target);
        const data = Object.fromEntries(formData);
        console.log('Добавление исполнителя:', data);
        alert('Исполнитель добавлен!');
        this.closeModal();
    }
}

let unitApp;
document.addEventListener('DOMContentLoaded', () => {
    unitApp = new IOSUnitPanel();
});
