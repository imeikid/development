// Общие функции для всех iOS-страниц
class IOSCommon {
    static init() {
        this.updateTime();
        this.setupNavigation();
        setInterval(() => this.updateTime(), 60000);
    }

    static updateTime() {
        const now = new Date();
        const timeString = now.getHours().toString().padStart(2, '0') + ':' + 
                         now.getMinutes().toString().padStart(2, '0');
        const timeElement = document.querySelector('.time');
        if (timeElement) {
            timeElement.textContent = timeString;
        }
    }

    static setupNavigation() {
        // Автоматически отмечаем активную страницу в навигации
        const currentPath = window.location.pathname;
        const navItems = document.querySelectorAll('.nav-item');
        
        navItems.forEach(item => {
            const href = item.getAttribute('href');
            if (currentPath === href || (currentPath === '/' && href === '/') || 
                (currentPath.includes(href) && href !== '/')) {
                item.classList.add('active');
            } else {
                item.classList.remove('active');
            }
        });
    }

    static showNotification(message, type = 'info') {
        // Создаем уведомление в стиле iOS
        const notification = document.createElement('div');
        notification.className = `ios-notification ${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <span class="notification-message">${message}</span>
                <button class="notification-close" onclick="this.parentElement.parentElement.remove()">×</button>
            </div>
        `;
        
        // Стили для уведомления
        if (!document.querySelector('.ios-notification')) {
            const style = document.createElement('style');
            style.textContent = `
                .ios-notification {
                    position: fixed;
                    top: 60px;
                    left: 50%;
                    transform: translateX(-50%);
                    background: white;
                    padding: 12px 16px;
                    border-radius: 12px;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                    border: 1px solid #e5e5ea;
                    z-index: 1000;
                    max-width: 300px;
                    animation: slideDown 0.3s ease;
                }
                @keyframes slideDown {
                    from { transform: translateX(-50%) translateY(-20px); opacity: 0; }
                    to { transform: translateX(-50%) translateY(0); opacity: 1; }
                }
                .notification-content {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    gap: 12px;
                }
                .notification-message {
                    font-size: 15px;
                    font-weight: 500;
                }
                .notification-close {
                    background: none;
                    border: none;
                    font-size: 18px;
                    cursor: pointer;
                    color: #8e8e93;
                }
            `;
            document.head.appendChild(style);
        }
        
        document.body.appendChild(notification);
        setTimeout(() => {
            if (notification.parentElement) {
                notification.remove();
            }
        }, 3000);
    }
}

// Инициализация при загрузке
document.addEventListener('DOMContentLoaded', () => {
    IOSCommon.init();
});
