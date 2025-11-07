class CRMSystem {
    constructor() {
        this.clients = JSON.parse(localStorage.getItem('crm_clients')) || [];
        this.init();
    }

    init() {
        this.loadClients();
        this.setupEventListeners();
        this.updateStats();
    }

    setupEventListeners() {
        const clientForm = document.getElementById('clientForm');
        if (clientForm) {
            clientForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.addClient();
            });
        }

        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => {
                this.searchClients(e.target.value);
            });
        }
    }

    addClient() {
        const formData = new FormData(document.getElementById('clientForm'));
        const client = {
            id: Date.now(),
            name: formData.get('name'),
            email: formData.get('email'),
            phone: formData.get('phone'),
            status: formData.get('status'),
            createdAt: new Date().toISOString()
        };

        this.clients.push(client);
        this.saveClients();
        this.loadClients();
        this.closeAddClientModal();
        document.getElementById('clientForm').reset();
        
        alert('Клиент успешно добавлен!');
    }

    loadClients() {
        const grid = document.getElementById('clientsGrid');
        if (!grid) return;
        
        grid.innerHTML = '';

        if (this.clients.length === 0) {
            grid.innerHTML = '<div class="no-clients">Нет клиентов. Добавьте первого клиента.</div>';
            return;
        }

        this.clients.forEach(client => {
            const card = this.createClientCard(client);
            grid.appendChild(card);
        });

        this.updateStats();
    }

    createClientCard(client) {
        const card = document.createElement('div');
        card.className = 'client-card';
        card.innerHTML = `
            <h3>${this.escapeHtml(client.name)}</h3>
            <p>📧 ${this.escapeHtml(client.email)}</p>
            <p>📞 ${this.escapeHtml(client.phone || 'Не указан')}</p>
            <div class="client-status">
                Статус: ${this.getStatusText(client.status)}
            </div>
            <button onclick="crm.deleteClient(${client.id})" class="btn btn-danger" style="margin-top: 10px; background: #e74c3c;">Удалить</button>
        `;
        return card;
    }

    getStatusText(status) {
        const statusMap = {
            'lead': 'Лид',
            'client': 'Клиент', 
            'vip': 'VIP клиент'
        };
        return statusMap[status] || status;
    }

    deleteClient(id) {
        if (confirm('Вы уверены, что хотите удалить клиента?')) {
            this.clients = this.clients.filter(client => client.id !== id);
            this.saveClients();
            this.loadClients();
            alert('Клиент удален!');
        }
    }

    searchClients(query) {
        const grid = document.getElementById('clientsGrid');
        if (!grid) return;
        
        if (!query.trim()) {
            this.loadClients();
            return;
        }

        const filteredClients = this.clients.filter(client => 
            client.name.toLowerCase().includes(query.toLowerCase()) ||
            client.email.toLowerCase().includes(query.toLowerCase())
        );
        
        grid.innerHTML = '';
        
        if (filteredClients.length === 0) {
            grid.innerHTML = '<div class="no-clients">Клиенты не найдены</div>';
            return;
        }
        
        filteredClients.forEach(client => {
            const card = this.createClientCard(client);
            grid.appendChild(card);
        });
    }

    updateStats() {
        const totalClients = document.getElementById('totalClients');
        const activeDeals = document.getElementById('activeDeals');
        
        if (totalClients) {
            totalClients.textContent = this.clients.length;
        }
        
        if (activeDeals) {
            const activeCount = this.clients.filter(c => c.status === 'client' || c.status === 'vip').length;
            activeDeals.textContent = activeCount;
        }
    }

    saveClients() {
        localStorage.setItem('crm_clients', JSON.stringify(this.clients));
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Глобальные функции для модального окна
function showAddClientModal() {
    const modal = document.getElementById('addClientModal');
    if (modal) {
        modal.style.display = 'block';
    }
}

function closeAddClientModal() {
    const modal = document.getElementById('addClientModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// Закрытие модального окна при клике вне его
window.addEventListener('click', (event) => {
    const modal = document.getElementById('addClientModal');
    if (event.target === modal) {
        closeAddClientModal();
    }
});

// Инициализация CRM системы при загрузке страницы
document.addEventListener('DOMContentLoaded', function() {
    window.crm = new CRMSystem();
});
