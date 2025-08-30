// Firebase Admin Functions
import { 
    collection, 
    getDocs, 
    addDoc, 
    updateDoc, 
    deleteDoc, 
    doc, 
    query, 
    orderBy, 
    limit, 
    where,
    onSnapshot,
    serverTimestamp 
} from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';

import { 
    createUserWithEmailAndPassword,
    signInWithEmailAndPassword,
    signOut,
    onAuthStateChanged 
} from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js';

import { 
    ref, 
    uploadBytes, 
    getDownloadURL, 
    deleteObject 
} from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-storage.js';

class AdminAPI {
    constructor() {
        this.db = window.db;
        this.auth = window.auth;
        this.storage = window.storage;
        this.setupAuthListener();
    }

    // Authentication
    setupAuthListener() {
        onAuthStateChanged(this.auth, (user) => {
            if (user) {
                console.log('Admin logged in:', user.email);
                this.initializeRealTimeListeners();
            } else {
                console.log('Admin not logged in');
                // Redirect to login page if needed
            }
        });
    }

    async adminLogin(email, password) {
        try {
            const userCredential = await signInWithEmailAndPassword(this.auth, email, password);
            return userCredential.user;
        } catch (error) {
            throw new Error('Login failed: ' + error.message);
        }
    }

    async adminLogout() {
        try {
            await signOut(this.auth);
            return true;
        } catch (error) {
            throw new Error('Logout failed: ' + error.message);
        }
    }

    // Real-time listeners
    initializeRealTimeListeners() {
        // Listen to users collection
        const usersQuery = query(collection(this.db, 'users'), orderBy('createdAt', 'desc'));
        onSnapshot(usersQuery, (snapshot) => {
            const users = [];
            snapshot.forEach((doc) => {
                users.push({ id: doc.id, ...doc.data() });
            });
            this.updateUsersTable(users);
            this.updateDashboardStats();
        });

        // Listen to study groups
        const groupsQuery = query(collection(this.db, 'studyGroups'), orderBy('createdAt', 'desc'));
        onSnapshot(groupsQuery, (snapshot) => {
            const groups = [];
            snapshot.forEach((doc) => {
                groups.push({ id: doc.id, ...doc.data() });
            });
            this.updateGroupsGrid(groups);
        });

        // Listen to activity logs
        const activityQuery = query(
            collection(this.db, 'activityLogs'), 
            orderBy('timestamp', 'desc'), 
            limit(10)
        );
        onSnapshot(activityQuery, (snapshot) => {
            const activities = [];
            snapshot.forEach((doc) => {
                activities.push({ id: doc.id, ...doc.data() });
            });
            this.updateRecentActivity(activities);
        });
    }

    // User Management
    async getUsers() {
        try {
            const querySnapshot = await getDocs(collection(this.db, 'users'));
            const users = [];
            querySnapshot.forEach((doc) => {
                users.push({ id: doc.id, ...doc.data() });
            });
            return users;
        } catch (error) {
            throw new Error('Failed to fetch users: ' + error.message);
        }
    }

    async createUser(userData) {
        try {
            const docRef = await addDoc(collection(this.db, 'users'), {
                ...userData,
                createdAt: serverTimestamp(),
                status: 'active'
            });
            
            // Log activity
            await this.logActivity('user_created', `New user created: ${userData.name}`);
            
            return docRef.id;
        } catch (error) {
            throw new Error('Failed to create user: ' + error.message);
        }
    }

    async updateUser(userId, userData) {
        try {
            const userRef = doc(this.db, 'users', userId);
            await updateDoc(userRef, {
                ...userData,
                updatedAt: serverTimestamp()
            });
            
            await this.logActivity('user_updated', `User updated: ${userData.name || userId}`);
            
            return true;
        } catch (error) {
            throw new Error('Failed to update user: ' + error.message);
        }
    }

    async deleteUser(userId) {
        try {
            const userRef = doc(this.db, 'users', userId);
            await deleteDoc(userRef);
            
            await this.logActivity('user_deleted', `User deleted: ${userId}`);
            
            return true;
        } catch (error) {
            throw new Error('Failed to delete user: ' + error.message);
        }
    }

    // Study Groups Management
    async getStudyGroups() {
        try {
            const querySnapshot = await getDocs(collection(this.db, 'studyGroups'));
            const groups = [];
            querySnapshot.forEach((doc) => {
                groups.push({ id: doc.id, ...doc.data() });
            });
            return groups;
        } catch (error) {
            throw new Error('Failed to fetch study groups: ' + error.message);
        }
    }

    async createStudyGroup(groupData) {
        try {
            const docRef = await addDoc(collection(this.db, 'studyGroups'), {
                ...groupData,
                createdAt: serverTimestamp(),
                memberCount: 0,
                isActive: true
            });
            
            await this.logActivity('group_created', `Study group created: ${groupData.name}`);
            
            return docRef.id;
        } catch (error) {
            throw new Error('Failed to create study group: ' + error.message);
        }
    }

    async updateStudyGroup(groupId, groupData) {
        try {
            const groupRef = doc(this.db, 'studyGroups', groupId);
            await updateDoc(groupRef, {
                ...groupData,
                updatedAt: serverTimestamp()
            });
            
            await this.logActivity('group_updated', `Study group updated: ${groupData.name || groupId}`);
            
            return true;
        } catch (error) {
            throw new Error('Failed to update study group: ' + error.message);
        }
    }

    async deleteStudyGroup(groupId) {
        try {
            const groupRef = doc(this.db, 'studyGroups', groupId);
            await deleteDoc(groupRef);
            
            await this.logActivity('group_deleted', `Study group deleted: ${groupId}`);
            
            return true;
        } catch (error) {
            throw new Error('Failed to delete study group: ' + error.message);
        }
    }

    // Content Management
    async uploadContent(contentData, file) {
        try {
            let downloadURL = null;
            
            if (file) {
                const storageRef = ref(this.storage, `content/${Date.now()}_${file.name}`);
                const snapshot = await uploadBytes(storageRef, file);
                downloadURL = await getDownloadURL(snapshot.ref);
            }

            const docRef = await addDoc(collection(this.db, 'content'), {
                ...contentData,
                downloadURL: downloadURL,
                uploadedAt: serverTimestamp(),
                views: 0,
                downloads: 0
            });
            
            await this.logActivity('content_uploaded', `Content uploaded: ${contentData.title}`);
            
            return docRef.id;
        } catch (error) {
            throw new Error('Failed to upload content: ' + error.message);
        }
    }

    async getContent() {
        try {
            const querySnapshot = await getDocs(collection(this.db, 'content'));
            const content = [];
            querySnapshot.forEach((doc) => {
                content.push({ id: doc.id, ...doc.data() });
            });
            return content;
        } catch (error) {
            throw new Error('Failed to fetch content: ' + error.message);
        }
    }

    // Notifications
    async sendNotification(notificationData) {
        try {
            const docRef = await addDoc(collection(this.db, 'notifications'), {
                ...notificationData,
                sentAt: serverTimestamp(),
                status: 'sent'
            });
            
            // Here you would typically integrate with Firebase Cloud Messaging
            // or your notification service
            
            await this.logActivity('notification_sent', `Notification sent: ${notificationData.title}`);
            
            return docRef.id;
        } catch (error) {
            throw new Error('Failed to send notification: ' + error.message);
        }
    }

    // Analytics
    async getAnalyticsData(period = 30) {
        try {
            const endDate = new Date();
            const startDate = new Date();
            startDate.setDate(endDate.getDate() - period);

            // Get user registrations
            const userQuery = query(
                collection(this.db, 'users'),
                where('createdAt', '>=', startDate),
                where('createdAt', '<=', endDate)
            );
            const userSnapshot = await getDocs(userQuery);

            // Get study sessions
            const sessionQuery = query(
                collection(this.db, 'studySessions'),
                where('createdAt', '>=', startDate),
                where('createdAt', '<=', endDate)
            );
            const sessionSnapshot = await getDocs(sessionQuery);

            return {
                userRegistrations: userSnapshot.size,
                studySessions: sessionSnapshot.size,
                period: period
            };
        } catch (error) {
            throw new Error('Failed to fetch analytics data: ' + error.message);
        }
    }

    // Activity Logging
    async logActivity(type, description) {
        try {
            await addDoc(collection(this.db, 'activityLogs'), {
                type: type,
                description: description,
                timestamp: serverTimestamp(),
                admin: this.auth.currentUser?.email || 'system'
            });
        } catch (error) {
            console.error('Failed to log activity:', error);
        }
    }

    // Dashboard Stats
    async getDashboardStats() {
        try {
            const [usersSnapshot, groupsSnapshot, sessionsSnapshot] = await Promise.all([
                getDocs(collection(this.db, 'users')),
                getDocs(collection(this.db, 'studyGroups')),
                getDocs(collection(this.db, 'studySessions'))
            ]);

            return {
                totalUsers: usersSnapshot.size,
                activeGroups: groupsSnapshot.size,
                studySessions: sessionsSnapshot.size,
                engagementRate: Math.floor(Math.random() * 20) + 80 // Placeholder calculation
            };
        } catch (error) {
            throw new Error('Failed to fetch dashboard stats: ' + error.message);
        }
    }

    // UI Update Methods
    updateUsersTable(users) {
        const tableBody = document.getElementById('users-table-body');
        if (!tableBody) return;

        tableBody.innerHTML = users.map(user => `
            <tr>
                <td>${user.id.substring(0, 8)}...</td>
                <td>${user.name || 'N/A'}</td>
                <td>${user.email || 'N/A'}</td>
                <td>${user.createdAt ? new Date(user.createdAt.toDate()).toLocaleDateString() : 'N/A'}</td>
                <td><span class="status ${user.status || 'active'}">${user.status || 'Active'}</span></td>
                <td>
                    <button class="btn-icon" onclick="editUser('${user.id}')"><i class="fas fa-edit"></i></button>
                    <button class="btn-icon" onclick="deleteUser('${user.id}')"><i class="fas fa-trash"></i></button>
                </td>
            </tr>
        `).join('');
    }

    updateGroupsGrid(groups) {
        const groupsGrid = document.querySelector('.groups-grid');
        if (!groupsGrid) return;

        groupsGrid.innerHTML = groups.map(group => `
            <div class="group-card">
                <div class="group-header">
                    <h3>${group.name || 'Unnamed Group'}</h3>
                    <span class="group-members">${group.memberCount || 0} members</span>
                </div>
                <p class="group-description">${group.description || 'No description'}</p>
                <div class="group-stats">
                    <span><i class="fas fa-calendar"></i> Created: ${group.createdAt ? new Date(group.createdAt.toDate()).toLocaleDateString() : 'Unknown'}</span>
                    <span><i class="fas fa-clock"></i> Last active: ${group.lastActivity || 'Unknown'}</span>
                </div>
                <div class="group-actions">
                    <button class="btn btn-sm">View</button>
                    <button class="btn btn-sm">Edit</button>
                    <button class="btn btn-sm btn-danger" onclick="adminAPI.deleteStudyGroup('${group.id}')">Delete</button>
                </div>
            </div>
        `).join('');
    }

    updateRecentActivity(activities) {
        const activityList = document.querySelector('.activity-list');
        if (!activityList) return;

        activityList.innerHTML = activities.map(activity => `
            <div class="activity-item">
                <i class="fas fa-${this.getActivityIcon(activity.type)}"></i>
                <span>${activity.description}</span>
                <time>${activity.timestamp ? this.timeAgo(activity.timestamp.toDate()) : 'Unknown'}</time>
            </div>
        `).join('');
    }

    getActivityIcon(type) {
        const icons = {
            user_created: 'user-plus',
            user_updated: 'user-edit',
            user_deleted: 'user-minus',
            group_created: 'users',
            group_updated: 'users-cog',
            group_deleted: 'user-times',
            content_uploaded: 'file-upload',
            notification_sent: 'bell'
        };
        return icons[type] || 'info-circle';
    }

    timeAgo(date) {
        const seconds = Math.floor((new Date() - date) / 1000);
        
        let interval = seconds / 31536000;
        if (interval > 1) return Math.floor(interval) + " years ago";
        
        interval = seconds / 2592000;
        if (interval > 1) return Math.floor(interval) + " months ago";
        
        interval = seconds / 86400;
        if (interval > 1) return Math.floor(interval) + " days ago";
        
        interval = seconds / 3600;
        if (interval > 1) return Math.floor(interval) + " hours ago";
        
        interval = seconds / 60;
        if (interval > 1) return Math.floor(interval) + " minutes ago";
        
        return Math.floor(seconds) + " seconds ago";
    }
}

// Export for global use
window.AdminAPI = AdminAPI;
window.adminAPI = new AdminAPI();
