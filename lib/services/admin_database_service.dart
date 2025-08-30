import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_models.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/study_pack.dart';

class AdminDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String _adminCollection = 'admin_users';
  static const String _usersCollection = 'users';
  static const String _activityLogsCollection = 'admin_activity_logs';
  static const String _systemSettingsCollection = 'system_settings';
  static const String _notificationsCollection = 'admin_notifications';
  static const String _analyticsCollection = 'app_analytics';
  static const String _studyPacksCollection = 'study_packs';
  static const String _quizzesCollection = 'quizzes';

  // =================== Admin User Management ===================

  // Create admin user
  Future<void> createAdminUser(AdminUser admin) async {
    try {
      await _firestore.collection(_adminCollection).doc(admin.id).set(admin.toMap());
      await _logActivity(
        action: 'CREATE_ADMIN',
        targetType: 'admin',
        targetId: admin.id,
        details: {'name': admin.name, 'role': admin.role.name},
      );
    } catch (e) {
      throw Exception('Failed to create admin user: $e');
    }
  }

  // Get admin user by ID
  Future<AdminUser?> getAdminUser(String adminId) async {
    try {
      final doc = await _firestore.collection(_adminCollection).doc(adminId).get();
      if (doc.exists && doc.data() != null) {
        return AdminUser.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get admin user: $e');
    }
  }

  // Get admin user by email
  Future<AdminUser?> getAdminUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection(_adminCollection)
          .where('email', isEqualTo: email)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return AdminUser.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get admin user by email: $e');
    }
  }

  // Get all admin users
  Future<List<AdminUser>> getAllAdminUsers() async {
    try {
      final query = await _firestore
          .collection(_adminCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => AdminUser.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get admin users: $e');
    }
  }

  // Update admin user
  Future<void> updateAdminUser(AdminUser admin) async {
    try {
      await _firestore.collection(_adminCollection).doc(admin.id).update(admin.toMap());
      await _logActivity(
        action: 'UPDATE_ADMIN',
        targetType: 'admin',
        targetId: admin.id,
        details: {'name': admin.name, 'role': admin.role.name},
      );
    } catch (e) {
      throw Exception('Failed to update admin user: $e');
    }
  }

  // Delete admin user
  Future<void> deleteAdminUser(String adminId) async {
    try {
      await _firestore.collection(_adminCollection).doc(adminId).delete();
      await _logActivity(
        action: 'DELETE_ADMIN',
        targetType: 'admin',
        targetId: adminId,
      );
    } catch (e) {
      throw Exception('Failed to delete admin user: $e');
    }
  }

  // =================== Regular User Management ===================

  // Get all users with pagination and filters
  Future<List<UserModel>> getUsers({
    int limit = 50,
    DocumentSnapshot? startAfter,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) async {
    try {
      Query query = _firestore.collection(_usersCollection);

      // Add filters
      if (startDate != null && endDate != null) {
        query = query.where('createdAt', 
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      // Add ordering and pagination
      query = query.orderBy('createdAt', descending: true);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      query = query.limit(limit);

      final querySnapshot = await query.get();
      final users = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Apply search filter (client-side for now)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        return users.where((user) =>
          user.name.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery)
        ).toList();
      }

      return users;
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.id).update(user.toMap());
      await _logActivity(
        action: 'UPDATE_USER',
        targetType: 'user',
        targetId: user.id,
        details: {'name': user.name, 'email': user.email},
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
      await _logActivity(
        action: 'DELETE_USER',
        targetType: 'user',
        targetId: userId,
      );
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final user = await getUser(userId);
      if (user == null) return {};

      // Get quiz results count
      final quizResults = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .get();

      // Get study sessions
      final studySessions = await _firestore
          .collection('study_sessions')
          .where('userId', isEqualTo: userId)
          .get();

      // Get study packs created
      final studyPacks = await _firestore
          .collection(_studyPacksCollection)
          .where('createdBy', isEqualTo: userId)
          .get();

      // Calculate additional statistics
      double totalStudyHours = 0;
      double avgSessionMinutes = 0;
      int totalAchievements = 0;
      Map<String, dynamic> subjectBreakdown = {};
      
      // Calculate study hours from sessions
      for (var session in studySessions.docs) {
        final data = session.data() as Map<String, dynamic>;
        final duration = data['duration'] ?? 0; // in minutes
        totalStudyHours += duration / 60.0;
      }
      
      if (studySessions.docs.isNotEmpty) {
        avgSessionMinutes = (totalStudyHours * 60) / studySessions.docs.length;
      }

      // Mock subject breakdown (you can implement actual logic)
      if (quizResults.docs.isNotEmpty) {
        subjectBreakdown = {
          'Mathematics': {'accuracy': 85.5, 'quizzesTaken': 12},
          'Science': {'accuracy': 78.2, 'quizzesTaken': 8},
          'History': {'accuracy': 92.1, 'quizzesTaken': 5},
        };
      }

      return {
        'totalQuizzes': quizResults.docs.length,
        'totalStudyPacks': studyPacks.docs.length,
        'totalStudyHours': totalStudyHours.round(),
        'avgSessionMinutes': avgSessionMinutes.round(),
        'totalAchievements': totalAchievements,
        'studyStreak': user.studyStreak,
        'quizAccuracy': user.quizAccuracy,
        'joinDate': user.createdAt,
        'lastLogin': user.lastLoginAt,
        'subjectBreakdown': subjectBreakdown,
        'preferredStudyTime': 'Morning', // Mock data
        'mostActiveDay': 'Monday', // Mock data
        'consistencyScore': 75, // Mock data
      };
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }

  // Get user activities/logs
  Future<List<ActivityLog>> getUserActivities(String userId, {int limit = 50}) async {
    try {
      // For now, we'll create mock activity logs since we don't have user activity tracking yet
      // In a real implementation, you'd have a separate collection for user activities
      
      final user = await getUser(userId);
      if (user == null) return [];

      // Mock activities based on user data
      List<ActivityLog> activities = [];
      
      // Add login activity
      activities.add(ActivityLog(
        id: '${userId}_login_${DateTime.now().millisecondsSinceEpoch}',
        adminId: userId,
        adminName: user.name,
        action: 'login',
        targetType: 'user',
        targetId: userId,
        details: {'loginTime': user.lastLoginAt.toIso8601String()},
        timestamp: user.lastLoginAt,
        ipAddress: '192.168.1.1',
      ));

      // Add mock quiz completion activities
      final quizResults = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(limit ~/ 2)
          .get();

      for (var doc in quizResults.docs) {
        final data = doc.data();
        activities.add(ActivityLog(
          id: doc.id,
          adminId: userId,
          adminName: user.name,
          action: 'quiz_completed',
          targetType: 'quiz',
          targetId: data['quizId'],
          details: {
            'score': data['score'] ?? 0,
            'totalQuestions': data['totalQuestions'] ?? 0,
            'subject': data['subject'] ?? 'Unknown',
          },
          timestamp: (data['completedAt'] as Timestamp).toDate(),
          ipAddress: '192.168.1.1',
        ));
      }

      // Add mock study session activities
      final studySessions = await _firestore
          .collection('study_sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .limit(limit ~/ 2)
          .get();

      for (var doc in studySessions.docs) {
        final data = doc.data();
        activities.add(ActivityLog(
          id: doc.id,
          adminId: userId,
          adminName: user.name,
          action: 'study_session',
          targetType: 'session',
          targetId: doc.id,
          details: {
            'duration': data['duration'] ?? 0,
            'subject': data['subject'] ?? 'Unknown',
            'topicsStudied': data['topicsStudied'] ?? 1,
          },
          timestamp: (data['startTime'] as Timestamp).toDate(),
          ipAddress: '192.168.1.1',
        ));
      }

      // Sort by timestamp and limit
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities.take(limit).toList();
    } catch (e) {
      // Return empty list if there's an error, but still create a basic login activity
      final user = await getUser(userId);
      if (user != null) {
        return [
          ActivityLog(
            id: '${userId}_login_recent',
            adminId: userId,
            adminName: user.name,
            action: 'login',
            targetType: 'user',
            targetId: userId,
            details: {'loginTime': user.lastLoginAt.toIso8601String()},
            timestamp: user.lastLoginAt,
            ipAddress: '192.168.1.1',
          ),
        ];
      }
      return [];
    }
  }

  // =================== Analytics and Statistics ===================

  // Get app statistics
  Future<AppStatistics> getAppStatistics() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      // Get total users count
      final usersSnapshot = await _firestore.collection(_usersCollection).count().get();
      final totalUsers = usersSnapshot.count ?? 0;

      // Get new users today
      final newUsersToday = await _firestore
          .collection(_usersCollection)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .count()
          .get();

      // Get active users (logged in last 7 days)
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final activeUsersSnapshot = await _firestore
          .collection(_usersCollection)
          .where('lastLoginAt', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .count()
          .get();

      // Get quiz statistics
      final quizzesSnapshot = await _firestore.collection('quiz_results').count().get();
      final totalQuizzes = quizzesSnapshot.count ?? 0;

      final quizzesTodaySnapshot = await _firestore
          .collection('quiz_results')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .count()
          .get();

      // Get study packs and flashcards
      final studyPacksSnapshot = await _firestore.collection(_studyPacksCollection).count().get();
      
      return AppStatistics(
        totalUsers: totalUsers,
        activeUsers: activeUsersSnapshot.count ?? 0,
        newUsersToday: newUsersToday.count ?? 0,
        totalQuizzes: totalQuizzes,
        quizzesToday: quizzesTodaySnapshot.count ?? 0,
        totalStudyPacks: studyPacksSnapshot.count ?? 0,
        totalFlashcards: 0, // Calculate separately if needed
        averageSessionTime: 0.0, // Calculate from session data
        usersByCountry: {}, // Implement if location tracking is added
        popularSubjects: {}, // Calculate from quiz/study pack data
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get app statistics: $e');
    }
  }

  // Save app statistics
  Future<void> saveAppStatistics(AppStatistics stats) async {
    try {
      await _firestore
          .collection(_analyticsCollection)
          .doc('app_stats')
          .set(stats.toMap());
    } catch (e) {
      throw Exception('Failed to save app statistics: $e');
    }
  }

  // =================== Content Management ===================

  // Get all study packs
  Future<List<StudyPack>> getStudyPacks({int limit = 50}) async {
    try {
      final query = await _firestore
          .collection(_studyPacksCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add the ID to the data
            return StudyPack.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get study packs: $e');
    }
  }

  // Create study pack
  Future<void> createStudyPack(StudyPack studyPack) async {
    try {
      await _firestore.collection(_studyPacksCollection).add(studyPack.toMap());
      await _logActivity(
        action: 'CREATE_STUDY_PACK',
        targetType: 'content',
        details: {'title': studyPack.title, 'subject': studyPack.subject},
      );
    } catch (e) {
      throw Exception('Failed to create study pack: $e');
    }
  }

  // Update study pack
  Future<void> updateStudyPack(StudyPack studyPack) async {
    try {
      await _firestore.collection(_studyPacksCollection).doc(studyPack.id).update(studyPack.toMap());
      await _logActivity(
        action: 'UPDATE_STUDY_PACK',
        targetType: 'content',
        targetId: studyPack.id,
        details: {'title': studyPack.title, 'subject': studyPack.subject},
      );
    } catch (e) {
      throw Exception('Failed to update study pack: $e');
    }
  }

  // Delete study pack
  Future<void> deleteStudyPack(String studyPackId) async {
    try {
      await _firestore.collection(_studyPacksCollection).doc(studyPackId).delete();
      await _logActivity(
        action: 'DELETE_STUDY_PACK',
        targetType: 'content',
        targetId: studyPackId,
      );
    } catch (e) {
      throw Exception('Failed to delete study pack: $e');
    }
  }

  // Get quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = now.subtract(const Duration(days: 7));
      final monthStart = now.subtract(const Duration(days: 30));

      // Total quiz results
      final totalQuizResults = await _firestore
          .collection('quiz_results')
          .count()
          .get();

      // Today's quizzes
      final todayQuizzes = await _firestore
          .collection('quiz_results')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .count()
          .get();

      // Week's quizzes
      final weekQuizzes = await _firestore
          .collection('quiz_results')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .count()
          .get();

      // Average accuracy
      final quizResults = await _firestore
          .collection('quiz_results')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .limit(1000)
          .get();

      double totalAccuracy = 0;
      int validResults = 0;
      Map<String, int> subjectCounts = {};
      Map<String, double> subjectAccuracy = {};

      for (var doc in quizResults.docs) {
        final data = doc.data();
        final score = data['score'] ?? 0;
        final totalQuestions = data['totalQuestions'] ?? 1;
        final subject = data['subject'] ?? 'Unknown';
        
        if (totalQuestions > 0) {
          final accuracy = (score / totalQuestions) * 100;
          totalAccuracy += accuracy;
          validResults++;
          
          // Subject breakdown
          subjectCounts[subject] = (subjectCounts[subject] ?? 0) + 1;
          subjectAccuracy[subject] = (subjectAccuracy[subject] ?? 0) + accuracy;
        }
      }

      // Calculate averages per subject
      Map<String, double> avgSubjectAccuracy = {};
      subjectAccuracy.forEach((subject, totalAcc) {
        avgSubjectAccuracy[subject] = totalAcc / subjectCounts[subject]!;
      });

      return {
        'totalQuizzes': totalQuizResults.count,
        'todayQuizzes': todayQuizzes.count,
        'weekQuizzes': weekQuizzes.count,
        'averageAccuracy': validResults > 0 ? totalAccuracy / validResults : 0.0,
        'subjectBreakdown': subjectCounts,
        'subjectAccuracy': avgSubjectAccuracy,
        'lastUpdated': now,
      };
    } catch (e) {
      throw Exception('Failed to get quiz statistics: $e');
    }
  }

  // Suspend/Unsuspend user
  Future<void> suspendUser(String userId, DateTime? suspendUntil, String reason) async {
    try {
      final updates = {
        'isActive': false,
        'suspendedUntil': suspendUntil != null ? Timestamp.fromDate(suspendUntil) : null,
        'suspensionReason': reason,
      };
      
      await _firestore.collection(_usersCollection).doc(userId).update(updates);
      await _logActivity(
        action: 'SUSPEND_USER',
        targetType: 'user',
        targetId: userId,
        details: {'reason': reason, 'suspendUntil': suspendUntil?.toIso8601String()},
      );
    } catch (e) {
      throw Exception('Failed to suspend user: $e');
    }
  }

  // Unsuspend user
  Future<void> unsuspendUser(String userId) async {
    try {
      final updates = {
        'isActive': true,
        'suspendedUntil': null,
        'suspensionReason': null,
      };
      
      await _firestore.collection(_usersCollection).doc(userId).update(updates);
      await _logActivity(
        action: 'UNSUSPEND_USER',
        targetType: 'user',
        targetId: userId,
      );
    } catch (e) {
      throw Exception('Failed to unsuspend user: $e');
    }
  }

  // =================== System Settings ===================

  // Get system settings by category
  Future<List<SystemSettings>> getSystemSettings([String? category]) async {
    try {
      Query query = _firestore.collection(_systemSettingsCollection);
      
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      
      query = query.orderBy('category').orderBy('key');
      
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => SystemSettings.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get system settings: $e');
    }
  }

  // Update system setting
  Future<void> updateSystemSetting(SystemSettings setting) async {
    try {
      await _firestore.collection(_systemSettingsCollection).doc(setting.id).set(setting.toMap());
      await _logActivity(
        action: 'UPDATE_SETTING',
        targetType: 'system',
        targetId: setting.id,
        details: {'key': setting.key, 'value': setting.value.toString()},
      );
    } catch (e) {
      throw Exception('Failed to update system setting: $e');
    }
  }

  // =================== Notifications ===================

  // Create notification
  Future<void> createNotification(AdminNotification notification) async {
    try {
      await _firestore.collection(_notificationsCollection).add(notification.toMap());
      await _logActivity(
        action: 'CREATE_NOTIFICATION',
        targetType: 'notification',
        details: {'title': notification.title, 'targetUsers': notification.targetUsers.length},
      );
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Get notifications
  Future<List<AdminNotification>> getNotifications({int limit = 50}) async {
    try {
      final query = await _firestore
          .collection(_notificationsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => AdminNotification.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  // =================== Activity Logs ===================

  // Log admin activity
  Future<void> _logActivity({
    required String action,
    required String targetType,
    String? targetId,
    Map<String, dynamic>? details,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final admin = await getAdminUser(currentUser.uid);
      if (admin == null) return;

      final log = ActivityLog(
        id: '',
        adminId: admin.id,
        adminName: admin.name,
        action: action,
        targetType: targetType,
        targetId: targetId,
        details: details ?? {},
        timestamp: DateTime.now(),
        ipAddress: 'Unknown', // You can implement IP detection
      );

      await _firestore.collection(_activityLogsCollection).add(log.toMap());
    } catch (e) {
      // Don't throw error for logging failure
      print('Failed to log activity: $e');
    }
  }

  // Get activity logs
  Future<List<ActivityLog>> getActivityLogs({
    int limit = 100,
    String? adminId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_activityLogsCollection);

      if (adminId != null) {
        query = query.where('adminId', isEqualTo: adminId);
      }

      if (startDate != null && endDate != null) {
        query = query.where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      query = query.orderBy('timestamp', descending: true).limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => ActivityLog.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get activity logs: $e');
    }
  }

  // =================== Bulk Operations ===================

  // Bulk delete users
  Future<void> bulkDeleteUsers(List<String> userIds) async {
    try {
      final batch = _firestore.batch();
      
      for (String userId in userIds) {
        batch.delete(_firestore.collection(_usersCollection).doc(userId));
      }
      
      await batch.commit();
      await _logActivity(
        action: 'BULK_DELETE_USERS',
        targetType: 'user',
        details: {'count': userIds.length, 'userIds': userIds},
      );
    } catch (e) {
      throw Exception('Failed to bulk delete users: $e');
    }
  }

  // Export users data
  Future<List<Map<String, dynamic>>> exportUsersData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_usersCollection);
      
      if (startDate != null && endDate != null) {
        query = query.where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }
      
      final querySnapshot = await query.get();
      await _logActivity(
        action: 'EXPORT_USERS_DATA',
        targetType: 'user',
        details: {'count': querySnapshot.docs.length},
      );
      
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to export users data: $e');
    }
  }

  // Get dashboard quick stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));
      final weekStart = now.subtract(const Duration(days: 7));

      // Users stats
      final totalUsers = await _firestore.collection(_usersCollection).count().get();
      final newUsersToday = await _firestore
          .collection(_usersCollection)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .count()
          .get();
      final newUsersYesterday = await _firestore
          .collection(_usersCollection)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(yesterdayStart))
          .where('createdAt', isLessThan: Timestamp.fromDate(todayStart))
          .count()
          .get();
      final activeUsers = await _firestore
          .collection(_usersCollection)
          .where('lastLoginAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .count()
          .get();

      // Content stats
      final totalQuizzes = await _firestore.collection('quiz_results').count().get();
      final totalStudyPacks = await _firestore.collection(_studyPacksCollection).count().get();

      return {
        'totalUsers': totalUsers.count,
        'newUsersToday': newUsersToday.count,
        'newUsersYesterday': newUsersYesterday.count,
        'userGrowthRate': _calculateGrowthRate(newUsersToday.count, newUsersYesterday.count),
        'activeUsers': activeUsers.count,
        'totalQuizzes': totalQuizzes.count,
        'totalStudyPacks': totalStudyPacks.count,
        'lastUpdated': now,
      };
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  double _calculateGrowthRate(int? today, int? yesterday) {
    if (yesterday == null || yesterday == 0) return 0.0;
    if (today == null) return -100.0;
    return ((today - yesterday) / yesterday * 100);
  }

  // =================== Enhanced Analytics ===================

  // Get user engagement statistics
  Future<Map<String, dynamic>> getUserEngagementStats() async {
    try {
      // Get user sessions data
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      final sessionsSnapshot = await _firestore
          .collection('user_sessions')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();
      
      double totalSessionDuration = 0;
      int sessionCount = sessionsSnapshot.docs.length;
      
      for (var session in sessionsSnapshot.docs) {
        final data = session.data();
        totalSessionDuration += (data['duration'] ?? 0).toDouble();
      }
      
      double averageSessionDuration = sessionCount > 0 
          ? totalSessionDuration / sessionCount 
          : 0;
      
      // Calculate retention rate (simplified)
      final usersSnapshot = await _firestore.collection(_usersCollection).get();
      final totalUsers = usersSnapshot.docs.length;
      final activeUsersSnapshot = await _firestore
          .collection(_usersCollection)
          .where('lastLoginAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();
      final activeUsers = activeUsersSnapshot.docs.length;
      
      double retentionRate = totalUsers > 0 
          ? (activeUsers / totalUsers) * 100 
          : 0;
      
      return {
        'averageSessionDuration': averageSessionDuration,
        'retentionRate': retentionRate,
        'dailyActiveUsers': activeUsers,
        'sessionCount': sessionCount,
        'bounceRate': 12.5, // Mock data
        'pageViewsPerSession': 4.2, // Mock data
      };
    } catch (e) {
      print('Error getting user engagement stats: $e');
      return {
        'averageSessionDuration': 0.0,
        'retentionRate': 0.0,
        'dailyActiveUsers': 0,
        'sessionCount': 0,
        'bounceRate': 0.0,
        'pageViewsPerSession': 0.0,
      };
    }
  }

  // Get content performance statistics
  Future<Map<String, dynamic>> getContentPerformanceStats() async {
    try {
      final studyPacksSnapshot = await _firestore.collection(_studyPacksCollection).get();
      final studyPacks = studyPacksSnapshot.docs;
      
      List<Map<String, dynamic>> contentStats = [];
      
      for (var pack in studyPacks) {
        final data = pack.data() as Map<String, dynamic>;
        final packId = pack.id;
        
        // Get usage stats for this study pack (simplified)
        final usageSnapshot = await _firestore
            .collection('study_pack_usage')
            .where('studyPackId', isEqualTo: packId)
            .get();
        
        contentStats.add({
          'id': packId,
          'title': data['title'] ?? 'Unknown',
          'category': data['category'] ?? 'General',
          'views': usageSnapshot.docs.length,
          'rating': data['averageRating'] ?? 0.0,
          'completionRate': data['completionRate'] ?? 0.0,
        });
      }
      
      // Sort by views to find top performing content
      contentStats.sort((a, b) => (b['views'] as int).compareTo(a['views'] as int));
      
      return {
        'totalContent': studyPacks.length,
        'topContent': contentStats.take(5).toList(),
        'averageRating': contentStats.isEmpty 
            ? 0.0 
            : contentStats.map((c) => c['rating'] as double).reduce((a, b) => a + b) / contentStats.length,
        'averageViews': contentStats.isEmpty 
            ? 0 
            : contentStats.map((c) => c['views'] as int).reduce((a, b) => a + b) ~/ contentStats.length,
      };
    } catch (e) {
      print('Error getting content performance stats: $e');
      return {
        'totalContent': 0,
        'topContent': [],
        'averageRating': 0.0,
        'averageViews': 0,
      };
    }
  }

  // Get system health status
  Future<Map<String, dynamic>> getSystemHealthStatus() async {
    try {
      // Check database connectivity
      await _firestore.collection('health_check').limit(1).get();
      
      // Mock health checks for other services
      return {
        'database': {
          'status': 'healthy',
          'responseTime': 45, // ms
          'lastChecked': DateTime.now(),
        },
        'firebase': {
          'status': 'healthy',
          'responseTime': 120, // ms
          'lastChecked': DateTime.now(),
        },
        'pushNotifications': {
          'status': 'healthy',
          'deliveryRate': 98.5, // %
          'lastChecked': DateTime.now(),
        },
        'analytics': {
          'status': 'warning',
          'responseTime': 250, // ms
          'lastChecked': DateTime.now(),
        },
        'overall': 'healthy',
      };
    } catch (e) {
      print('Error getting system health status: $e');
      return {
        'database': {'status': 'error', 'responseTime': 0, 'lastChecked': DateTime.now()},
        'firebase': {'status': 'unknown', 'responseTime': 0, 'lastChecked': DateTime.now()},
        'pushNotifications': {'status': 'unknown', 'deliveryRate': 0, 'lastChecked': DateTime.now()},
        'analytics': {'status': 'unknown', 'responseTime': 0, 'lastChecked': DateTime.now()},
        'overall': 'error',
      };
    }
  }

  // Get revenue statistics
  Future<Map<String, dynamic>> getRevenueStats() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);
      
      // Get subscription data (mock implementation)
      final subscriptionsSnapshot = await _firestore.collection('subscriptions').get();
      final subscriptions = subscriptionsSnapshot.docs;
      
      double weeklyRevenue = 0;
      double monthlyRevenue = 0;
      int activeSubscriptions = 0;
      
      for (var sub in subscriptions) {
        final data = sub.data() as Map<String, dynamic>;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final amount = (data['amount'] ?? 0).toDouble();
        final isActive = data['isActive'] ?? false;
        
        if (isActive) {
          activeSubscriptions++;
          
          if (createdAt.isAfter(weekStart)) {
            weeklyRevenue += amount;
          }
          
          if (createdAt.isAfter(monthStart)) {
            monthlyRevenue += amount;
          }
        }
      }
      
      return {
        'weeklyRevenue': weeklyRevenue,
        'monthlyRevenue': monthlyRevenue,
        'activeSubscriptions': activeSubscriptions,
        'averageRevenuePerUser': activeSubscriptions > 0 
            ? monthlyRevenue / activeSubscriptions 
            : 0,
        'conversionRate': 15.3, // Mock data
        'churnRate': 5.2, // Mock data
      };
    } catch (e) {
      print('Error getting revenue stats: $e');
      return {
        'weeklyRevenue': 0.0,
        'monthlyRevenue': 0.0,
        'activeSubscriptions': 0,
        'averageRevenuePerUser': 0.0,
        'conversionRate': 0.0,
        'churnRate': 0.0,
      };
    }
  }
}
