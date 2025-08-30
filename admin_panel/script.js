// Global variables
let currentSection = 'dashboard';
let charts = {};
let adminAPI = null;

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Wait for Firebase to initialize
    setTimeout(() => {
        initializeApp();
        initializeCharts();
        loadDashboardData();
        
        // Initialize Firebase Admin API after Firebase is loaded
        if (window.AdminAPI) {
            adminAPI = window.adminAPI;
            loadRealData();
        }
    }, 1000);
});

// Initialize the application
function initializeApp() {
    // Set initial active section
    showSection('dashboard');
    
    // Add event listeners
    setupEventListeners();
    
    // Initialize modals
    setupModals();
}

// Setup event listeners
function setupEventListeners() {
    // Search functionality
    const searchInput = document.querySelector('.search-box input');
    if (searchInput) {
        searchInput.addEventListener('input', handleSearch);
    }
    
    // Analytics period filter
    const periodFilter = document.getElementById('analytics-period');
    if (periodFilter) {
        periodFilter.addEventListener('change', updateAnalytics);
    }
}

// Navigation functions
function showSection(sectionId) {
    // Hide all sections
    const sections = document.querySelectorAll('.content-section');
    sections.forEach(section => {
        section.classList.remove('active');
    });
    
    // Show selected section
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');
        currentSection = sectionId;
        
        // Update page title
        const pageTitle = document.getElementById('page-title');
        const navLink = document.querySelector(`[onclick="showSection('${sectionId}')"]`);
        if (pageTitle && navLink) {
            pageTitle.textContent = navLink.textContent.trim();
        }
        
        // Update active nav link
        updateActiveNavLink(sectionId);
        
        // Load section-specific data
        loadSectionData(sectionId);
    }
}

function updateActiveNavLink(sectionId) {
    // Remove active class from all nav links
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.classList.remove('active');
    });
    
    // Add active class to current nav link
    const activeLink = document.querySelector(`[onclick="showSection('${sectionId}')"]`);
    if (activeLink) {
        activeLink.classList.add('active');
    }
}

// Sidebar toggle
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.querySelector('.main-content');
    
    if (window.innerWidth <= 768) {
        sidebar.classList.toggle('active');
    } else {
        sidebar.classList.toggle('collapsed');
        mainContent.classList.toggle('expanded');
    }
}

// Search functionality
function handleSearch(event) {
    const searchTerm = event.target.value.toLowerCase();
    console.log('Searching for:', searchTerm);
    // Implement search logic based on current section
    // This is a placeholder for actual search functionality
}

// Dashboard functions
function loadDashboardData() {
    // Simulate API calls to load dashboard data
    updateDashboardStats();
    updateRecentActivity();
}

function updateDashboardStats() {
    // Simulate real-time data updates
    const stats = {
        totalUsers: Math.floor(Math.random() * 1000) + 1000,
        activeGroups: Math.floor(Math.random() * 50) + 50,
        studySessions: Math.floor(Math.random() * 200) + 300,
        engagementRate: Math.floor(Math.random() * 20) + 80
    };
    
    document.getElementById('total-users').textContent = stats.totalUsers.toLocaleString();
    document.getElementById('active-groups').textContent = stats.activeGroups;
    document.getElementById('study-sessions').textContent = stats.studySessions;
    document.getElementById('engagement-rate').textContent = stats.engagementRate + '%';
}

function updateRecentActivity() {
    // This would typically fetch from an API
    console.log('Updated recent activity');
}

// Chart initialization and management
function initializeCharts() {
    initUserGrowthChart();
    initSubjectChart();
    initActivityChart();
    initSubjectsChart();
    initDeviceChart();
}

function initUserGrowthChart() {
    const ctx = document.getElementById('userGrowthChart');
    if (!ctx) return;
    
    charts.userGrowth = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            datasets: [{
                label: 'New Users',
                data: [12, 19, 3, 5, 2, 3],
                borderColor: '#667eea',
                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true
                }
            },
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });
}

function initSubjectChart() {
    const ctx = document.getElementById('subjectChart');
    if (!ctx) return;
    
    charts.subject = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'English'],
            datasets: [{
                data: [30, 25, 20, 15, 10],
                backgroundColor: [
                    '#667eea',
                    '#f093fb',
                    '#4facfe',
                    '#43e97b',
                    '#ffd93d'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
}

function initActivityChart() {
    const ctx = document.getElementById('activityChart');
    if (!ctx) return;
    
    charts.activity = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            datasets: [{
                label: 'Active Users',
                data: [65, 59, 80, 81, 56, 55, 40],
                backgroundColor: 'rgba(102, 126, 234, 0.6)',
                borderColor: '#667eea',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
}

function initSubjectsChart() {
    const ctx = document.getElementById('subjectsChart');
    if (!ctx) return;
    
    charts.subjects = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: ['Math', 'Science', 'English', 'History'],
            datasets: [{
                data: [35, 30, 20, 15],
                backgroundColor: ['#667eea', '#f093fb', '#4facfe', '#43e97b']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });
}

function initDeviceChart() {
    const ctx = document.getElementById('deviceChart');
    if (!ctx) return;
    
    charts.device = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Mobile', 'Desktop', 'Tablet'],
            datasets: [{
                data: [60, 30, 10],
                backgroundColor: ['#667eea', '#f093fb', '#4facfe']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });
}

// Section-specific data loading
function loadSectionData(sectionId) {
    switch(sectionId) {
        case 'dashboard':
            loadDashboardData();
            break;
        case 'users':
            loadUsersData();
            break;
        case 'groups':
            loadGroupsData();
            break;
        case 'content':
            loadContentData();
            break;
        case 'analytics':
            loadAnalyticsData();
            break;
        case 'notifications':
            loadNotificationsData();
            break;
        case 'settings':
            loadSettingsData();
            break;
    }
}

// Users management functions
function loadUsersData() {
    console.log('Loading users data...');
    // Implement API call to load users
}

function addUser() {
    showModal('Add New User', `
        <form onsubmit="saveUser(event)">
            <div class="form-group">
                <label for="user-name">Name</label>
                <input type="text" id="user-name" required>
            </div>
            <div class="form-group">
                <label for="user-email">Email</label>
                <input type="email" id="user-email" required>
            </div>
            <div class="form-group">
                <label for="user-role">Role</label>
                <select id="user-role">
                    <option value="student">Student</option>
                    <option value="teacher">Teacher</option>
                    <option value="admin">Admin</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Save User</button>
        </form>
    `);
}

function editUser(userId) {
    console.log('Editing user:', userId);
    // Implement edit user functionality
    showModal('Edit User', `
        <form onsubmit="updateUser(event, ${userId})">
            <div class="form-group">
                <label for="edit-user-name">Name</label>
                <input type="text" id="edit-user-name" value="John Doe" required>
            </div>
            <div class="form-group">
                <label for="edit-user-email">Email</label>
                <input type="email" id="edit-user-email" value="john@example.com" required>
            </div>
            <div class="form-group">
                <label for="edit-user-role">Role</label>
                <select id="edit-user-role">
                    <option value="student" selected>Student</option>
                    <option value="teacher">Teacher</option>
                    <option value="admin">Admin</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Update User</button>
        </form>
    `);
}

function deleteUser(userId) {
    if (confirm('Are you sure you want to delete this user?')) {
        console.log('Deleting user:', userId);
        // Implement delete user functionality
        showNotification('User deleted successfully', 'success');
    }
}

function saveUser(event) {
    event.preventDefault();
    const name = document.getElementById('user-name').value;
    const email = document.getElementById('user-email').value;
    const role = document.getElementById('user-role').value;
    
    console.log('Saving user:', { name, email, role });
    // Implement save user API call
    
    closeModal();
    showNotification('User added successfully', 'success');
}

function updateUser(event, userId) {
    event.preventDefault();
    const name = document.getElementById('edit-user-name').value;
    const email = document.getElementById('edit-user-email').value;
    const role = document.getElementById('edit-user-role').value;
    
    console.log('Updating user:', userId, { name, email, role });
    // Implement update user API call
    
    closeModal();
    showNotification('User updated successfully', 'success');
}

// Groups management functions
function loadGroupsData() {
    console.log('Loading groups data...');
    // Implement API call to load groups
}

function createGroup() {
    showModal('Create Study Group', `
        <form onsubmit="saveGroup(event)">
            <div class="form-group">
                <label for="group-name">Group Name</label>
                <input type="text" id="group-name" required>
            </div>
            <div class="form-group">
                <label for="group-description">Description</label>
                <textarea id="group-description" rows="3"></textarea>
            </div>
            <div class="form-group">
                <label for="group-subject">Subject</label>
                <select id="group-subject">
                    <option value="mathematics">Mathematics</option>
                    <option value="physics">Physics</option>
                    <option value="chemistry">Chemistry</option>
                    <option value="biology">Biology</option>
                    <option value="english">English</option>
                </select>
            </div>
            <div class="form-group">
                <label for="group-privacy">Privacy</label>
                <select id="group-privacy">
                    <option value="public">Public</option>
                    <option value="private">Private</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Create Group</button>
        </form>
    `);
}

function saveGroup(event) {
    event.preventDefault();
    const name = document.getElementById('group-name').value;
    const description = document.getElementById('group-description').value;
    const subject = document.getElementById('group-subject').value;
    const privacy = document.getElementById('group-privacy').value;
    
    console.log('Saving group:', { name, description, subject, privacy });
    // Implement save group API call
    
    closeModal();
    showNotification('Study group created successfully', 'success');
}

// Content management functions
function loadContentData() {
    console.log('Loading content data...');
    // Implement API call to load content
}

function uploadContent() {
    showModal('Upload Content', `
        <form onsubmit="saveContent(event)">
            <div class="form-group">
                <label for="content-title">Title</label>
                <input type="text" id="content-title" required>
            </div>
            <div class="form-group">
                <label for="content-type">Content Type</label>
                <select id="content-type">
                    <option value="document">Document</option>
                    <option value="video">Video</option>
                    <option value="audio">Audio</option>
                    <option value="image">Image</option>
                </select>
            </div>
            <div class="form-group">
                <label for="content-subject">Subject</label>
                <select id="content-subject">
                    <option value="mathematics">Mathematics</option>
                    <option value="physics">Physics</option>
                    <option value="chemistry">Chemistry</option>
                    <option value="biology">Biology</option>
                    <option value="english">English</option>
                </select>
            </div>
            <div class="form-group">
                <label for="content-file">File</label>
                <input type="file" id="content-file" required>
            </div>
            <div class="form-group">
                <label for="content-description">Description</label>
                <textarea id="content-description" rows="3"></textarea>
            </div>
            <button type="submit" class="btn btn-primary">Upload Content</button>
        </form>
    `);
}

function saveContent(event) {
    event.preventDefault();
    const title = document.getElementById('content-title').value;
    const type = document.getElementById('content-type').value;
    const subject = document.getElementById('content-subject').value;
    const file = document.getElementById('content-file').files[0];
    const description = document.getElementById('content-description').value;
    
    console.log('Saving content:', { title, type, subject, file, description });
    // Implement save content API call
    
    closeModal();
    showNotification('Content uploaded successfully', 'success');
}

// Analytics functions
function loadAnalyticsData() {
    console.log('Loading analytics data...');
    // Implement API call to load analytics
}

function updateAnalytics() {
    const period = document.getElementById('analytics-period').value;
    console.log('Updating analytics for period:', period);
    // Implement analytics update based on selected period
}

// Notifications functions
function loadNotificationsData() {
    console.log('Loading notifications data...');
    // Implement API call to load notifications
}

function sendNotification() {
    const type = document.getElementById('notification-type').value;
    const title = document.getElementById('notification-title').value;
    const message = document.getElementById('notification-message').value;
    
    if (!title || !message) {
        showNotification('Please fill in all fields', 'error');
        return;
    }
    
    console.log('Sending notification:', { type, title, message });
    // Implement send notification API call
    
    // Clear form
    document.getElementById('notification-title').value = '';
    document.getElementById('notification-message').value = '';
    
    showNotification('Notification sent successfully', 'success');
}

// Settings functions
function loadSettingsData() {
    console.log('Loading settings data...');
    // Implement API call to load settings
}

// Modal functions
function setupModals() {
    const modal = document.getElementById('modal');
    if (modal) {
        modal.addEventListener('click', function(event) {
            if (event.target === modal) {
                closeModal();
            }
        });
    }
}

function showModal(title, content) {
    const modal = document.getElementById('modal');
    const modalBody = document.getElementById('modal-body');
    
    modalBody.innerHTML = `<h2>${title}</h2>${content}`;
    modal.style.display = 'block';
}

function closeModal() {
    const modal = document.getElementById('modal');
    modal.style.display = 'none';
}

// Notification system
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Style the notification
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 6px;
        color: white;
        font-weight: 500;
        z-index: 3000;
        animation: slideIn 0.3s ease;
    `;
    
    // Set background color based on type
    switch(type) {
        case 'success':
            notification.style.backgroundColor = '#4caf50';
            break;
        case 'error':
            notification.style.backgroundColor = '#f44336';
            break;
        case 'warning':
            notification.style.backgroundColor = '#ff9800';
            break;
        default:
            notification.style.backgroundColor = '#2196f3';
    }
    
    // Add to document
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Logout function
function logout() {
    if (confirm('Are you sure you want to logout?')) {
        console.log('Logging out...');
        // Implement logout functionality
        // For demo purposes, just reload the page
        window.location.reload();
    }
}

// Utility functions
function formatDate(date) {
    return new Date(date).toLocaleDateString();
}

function formatNumber(num) {
    return num.toLocaleString();
}

// Add animation styles
const animationStyles = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;

// Add styles to head
const styleSheet = document.createElement('style');
styleSheet.textContent = animationStyles;
document.head.appendChild(styleSheet);

// Auto-refresh dashboard data every 30 seconds
setInterval(() => {
    if (currentSection === 'dashboard') {
        updateDashboardStats();
    }
}, 30000);

// Handle window resize for responsive design
window.addEventListener('resize', function() {
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.querySelector('.main-content');
    
    if (window.innerWidth > 768) {
        sidebar.classList.remove('active');
        if (sidebar.classList.contains('collapsed')) {
            mainContent.classList.add('expanded');
        } else {
            mainContent.classList.remove('expanded');
        }
    } else {
        sidebar.classList.remove('collapsed');
        mainContent.classList.remove('expanded');
    }
});

// Load real data from Firebase
function loadRealData() {
    if (!adminAPI) return;
    
    // Load real dashboard stats
    adminAPI.getDashboardStats().then(stats => {
        document.getElementById('total-users').textContent = stats.totalUsers.toLocaleString();
        document.getElementById('active-groups').textContent = stats.activeGroups;
        document.getElementById('study-sessions').textContent = stats.studySessions;
        document.getElementById('engagement-rate').textContent = stats.engagementRate + '%';
    }).catch(error => {
        console.error('Error loading dashboard stats:', error);
    });
}

// Enhanced functions with Firebase integration
function saveUserFirebase(event) {
    event.preventDefault();
    const name = document.getElementById('user-name').value;
    const email = document.getElementById('user-email').value;
    const role = document.getElementById('user-role').value;
    
    if (!adminAPI) {
        showNotification('Firebase not initialized', 'error');
        return;
    }
    
    adminAPI.createUser({ name, email, role }).then(() => {
        closeModal();
        showNotification('User added successfully', 'success');
    }).catch(error => {
        showNotification('Error adding user: ' + error.message, 'error');
    });
}

function saveGroupFirebase(event) {
    event.preventDefault();
    const name = document.getElementById('group-name').value;
    const description = document.getElementById('group-description').value;
    const subject = document.getElementById('group-subject').value;
    const privacy = document.getElementById('group-privacy').value;
    
    if (!adminAPI) {
        showNotification('Firebase not initialized', 'error');
        return;
    }
    
    adminAPI.createStudyGroup({ 
        name, 
        description, 
        subject, 
        privacy: privacy === 'private' 
    }).then(() => {
        closeModal();
        showNotification('Study group created successfully', 'success');
    }).catch(error => {
        showNotification('Error creating group: ' + error.message, 'error');
    });
}

function saveContentFirebase(event) {
    event.preventDefault();
    const title = document.getElementById('content-title').value;
    const type = document.getElementById('content-type').value;
    const subject = document.getElementById('content-subject').value;
    const file = document.getElementById('content-file').files[0];
    const description = document.getElementById('content-description').value;
    
    if (!adminAPI) {
        showNotification('Firebase not initialized', 'error');
        return;
    }
    
    const contentData = {
        title,
        type,
        subject,
        description
    };
    
    showNotification('Uploading content...', 'info');
    
    adminAPI.uploadContent(contentData, file).then(() => {
        closeModal();
        showNotification('Content uploaded successfully', 'success');
    }).catch(error => {
        showNotification('Error uploading content: ' + error.message, 'error');
    });
}

function sendNotificationFirebase() {
    const type = document.getElementById('notification-type').value;
    const title = document.getElementById('notification-title').value;
    const message = document.getElementById('notification-message').value;
    
    if (!title || !message) {
        showNotification('Please fill in all fields', 'error');
        return;
    }
    
    if (!adminAPI) {
        showNotification('Firebase not initialized', 'error');
        return;
    }
    
    const notificationData = {
        title,
        message,
        type,
        targetType: type
    };
    
    adminAPI.sendNotification(notificationData).then(() => {
        document.getElementById('notification-title').value = '';
        document.getElementById('notification-message').value = '';
        showNotification('Notification sent successfully', 'success');
    }).catch(error => {
        showNotification('Error sending notification: ' + error.message, 'error');
    });
}

// Enhanced search functionality
function handleSearchEnhanced(event) {
    const searchTerm = event.target.value.toLowerCase();
    
    if (!searchTerm) return;
    
    // Search based on current section
    switch(currentSection) {
        case 'users':
            searchUsers(searchTerm);
            break;
        case 'groups':
            searchGroups(searchTerm);
            break;
        case 'content':
            searchContent(searchTerm);
            break;
    }
}

function searchUsers(term) {
    const tableRows = document.querySelectorAll('#users-table-body tr');
    tableRows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(term) ? '' : 'none';
    });
}

function searchGroups(term) {
    const groupCards = document.querySelectorAll('.group-card');
    groupCards.forEach(card => {
        const text = card.textContent.toLowerCase();
        card.style.display = text.includes(term) ? '' : 'none';
    });
}

function searchContent(term) {
    const contentItems = document.querySelectorAll('.content-item');
    contentItems.forEach(item => {
        const text = item.textContent.toLowerCase();
        item.style.display = text.includes(term) ? '' : 'none';
    });
}

// Data export functionality
function exportData(type) {
    if (!adminAPI) {
        showNotification('Firebase not initialized', 'error');
        return;
    }
    
    let promise;
    
    switch(type) {
        case 'users':
            promise = adminAPI.getUsers();
            break;
        case 'groups':
            promise = adminAPI.getStudyGroups();
            break;
        case 'content':
            promise = adminAPI.getContent();
            break;
        default:
            showNotification('Unknown export type', 'error');
            return;
    }
    
    promise.then(data => {
        const csv = convertToCSV(data);
        downloadCSV(csv, `${type}_export_${new Date().toISOString().split('T')[0]}.csv`);
        showNotification(`${type} data exported successfully`, 'success');
    }).catch(error => {
        showNotification('Error exporting data: ' + error.message, 'error');
    });
}

function convertToCSV(data) {
    if (!data || data.length === 0) return '';
    
    const headers = Object.keys(data[0]);
    const csvHeaders = headers.join(',');
    const csvRows = data.map(row => {
        return headers.map(header => {
            const value = row[header];
            return typeof value === 'string' ? `"${value.replace(/"/g, '""')}"` : value;
        }).join(',');
    });
    
    return [csvHeaders, ...csvRows].join('\n');
}

function downloadCSV(csv, filename) {
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.setAttribute('hidden', '');
    a.setAttribute('href', url);
    a.setAttribute('download', filename);
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
}

// Bulk operations
function bulkDeleteUsers() {
    const selectedUsers = document.querySelectorAll('input[type="checkbox"]:checked');
    if (selectedUsers.length === 0) {
        showNotification('Please select users to delete', 'warning');
        return;
    }
    
    if (!confirm(`Are you sure you want to delete ${selectedUsers.length} users?`)) {
        return;
    }
    
    // Implementation for bulk delete
    showNotification('Bulk delete functionality would be implemented here', 'info');
}

console.log('Study Buddy Admin Panel initialized successfully!');

// Expose functions globally for Firebase callbacks
window.saveUserFirebase = saveUserFirebase;
window.saveGroupFirebase = saveGroupFirebase;
window.saveContentFirebase = saveContentFirebase;
window.sendNotificationFirebase = sendNotificationFirebase;
