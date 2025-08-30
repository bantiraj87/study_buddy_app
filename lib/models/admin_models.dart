import 'package:cloud_firestore/cloud_firestore.dart';

// Admin Role Enum
enum AdminRole {
  superAdmin,
  admin,
  moderator,
  contentManager,
  analyst;

  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.admin:
        return 'Admin';
      case AdminRole.moderator:
        return 'Moderator';
      case AdminRole.contentManager:
        return 'Content Manager';
      case AdminRole.analyst:
        return 'Analyst';
    }
  }

  List<Permission> get permissions {
    switch (this) {
      case AdminRole.superAdmin:
        return Permission.values;
      case AdminRole.admin:
        return [
          Permission.viewUsers,
          Permission.editUsers,
          Permission.deleteUsers,
          Permission.viewContent,
          Permission.editContent,
          Permission.deleteContent,
          Permission.viewAnalytics,
          Permission.manageSettings,
          Permission.sendNotifications,
        ];
      case AdminRole.moderator:
        return [
          Permission.viewUsers,
          Permission.editUsers,
          Permission.viewContent,
          Permission.editContent,
          Permission.viewAnalytics,
        ];
      case AdminRole.contentManager:
        return [
          Permission.viewContent,
          Permission.editContent,
          Permission.deleteContent,
          Permission.createContent,
          Permission.viewAnalytics,
        ];
      case AdminRole.analyst:
        return [
          Permission.viewUsers,
          Permission.viewContent,
          Permission.viewAnalytics,
          Permission.exportData,
        ];
    }
  }
}

// Permission Enum
enum Permission {
  // User Management
  viewUsers,
  editUsers,
  deleteUsers,
  banUsers,
  
  // Content Management
  viewContent,
  createContent,
  editContent,
  deleteContent,
  
  // Analytics
  viewAnalytics,
  exportData,
  
  // System
  manageSettings,
  manageAdmins,
  sendNotifications,
  viewLogs,
  
  // Advanced
  databaseAccess,
  systemMaintenance;

  String get displayName {
    switch (this) {
      case Permission.viewUsers:
        return 'View Users';
      case Permission.editUsers:
        return 'Edit Users';
      case Permission.deleteUsers:
        return 'Delete Users';
      case Permission.banUsers:
        return 'Ban/Unban Users';
      case Permission.viewContent:
        return 'View Content';
      case Permission.createContent:
        return 'Create Content';
      case Permission.editContent:
        return 'Edit Content';
      case Permission.deleteContent:
        return 'Delete Content';
      case Permission.viewAnalytics:
        return 'View Analytics';
      case Permission.exportData:
        return 'Export Data';
      case Permission.manageSettings:
        return 'Manage Settings';
      case Permission.manageAdmins:
        return 'Manage Admins';
      case Permission.sendNotifications:
        return 'Send Notifications';
      case Permission.viewLogs:
        return 'View System Logs';
      case Permission.databaseAccess:
        return 'Database Access';
      case Permission.systemMaintenance:
        return 'System Maintenance';
    }
  }
}

// Admin User Model
class AdminUser {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final AdminRole role;
  final List<Permission> customPermissions;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;
  final String? createdBy;
  final Map<String, dynamic> metadata;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.role,
    this.customPermissions = const [],
    required this.createdAt,
    required this.lastLoginAt,
    this.isActive = true,
    this.createdBy,
    this.metadata = const {},
  });

  // Get all permissions (role-based + custom)
  List<Permission> get allPermissions {
    final rolePermissions = role.permissions;
    final combined = {...rolePermissions, ...customPermissions};
    return combined.toList();
  }

  bool hasPermission(Permission permission) {
    return allPermissions.contains(permission);
  }

  factory AdminUser.fromMap(Map<String, dynamic> map, String id) {
    return AdminUser(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      role: AdminRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => AdminRole.moderator,
      ),
      customPermissions: (map['customPermissions'] as List<dynamic>? ?? [])
          .map((p) => Permission.values.firstWhere(
                (perm) => perm.name == p,
                orElse: () => Permission.viewUsers,
              ))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      createdBy: map['createdBy'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role.name,
      'customPermissions': customPermissions.map((p) => p.name).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isActive': isActive,
      'createdBy': createdBy,
      'metadata': metadata,
    };
  }

  AdminUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    AdminRole? role,
    List<Permission>? customPermissions,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      customPermissions: customPermissions ?? this.customPermissions,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Activity Log Model
class ActivityLog {
  final String id;
  final String adminId;
  final String adminName;
  final String action;
  final String targetType; // user, content, system, etc.
  final String? targetId;
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final String ipAddress;

  ActivityLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.targetType,
    this.targetId,
    this.details = const {},
    required this.timestamp,
    required this.ipAddress,
  });

  factory ActivityLog.fromMap(Map<String, dynamic> map, String id) {
    return ActivityLog(
      id: id,
      adminId: map['adminId'] ?? '',
      adminName: map['adminName'] ?? '',
      action: map['action'] ?? '',
      targetType: map['targetType'] ?? '',
      targetId: map['targetId'],
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      ipAddress: map['ipAddress'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'adminName': adminName,
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
      'ipAddress': ipAddress,
    };
  }
}

// System Settings Model
class SystemSettings {
  final String id;
  final String category;
  final String key;
  final dynamic value;
  final String type; // string, number, boolean, json
  final String description;
  final DateTime updatedAt;
  final String updatedBy;

  SystemSettings({
    required this.id,
    required this.category,
    required this.key,
    required this.value,
    required this.type,
    required this.description,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory SystemSettings.fromMap(Map<String, dynamic> map, String id) {
    return SystemSettings(
      id: id,
      category: map['category'] ?? '',
      key: map['key'] ?? '',
      value: map['value'],
      type: map['type'] ?? 'string',
      description: map['description'] ?? '',
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      updatedBy: map['updatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'key': key,
      'value': value,
      'type': type,
      'description': description,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
    };
  }
}

// App Statistics Model
class AppStatistics {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final int totalQuizzes;
  final int quizzesToday;
  final int totalStudyPacks;
  final int totalFlashcards;
  final double averageSessionTime;
  final Map<String, int> usersByCountry;
  final Map<String, int> popularSubjects;
  final DateTime lastUpdated;

  AppStatistics({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.newUsersToday = 0,
    this.totalQuizzes = 0,
    this.quizzesToday = 0,
    this.totalStudyPacks = 0,
    this.totalFlashcards = 0,
    this.averageSessionTime = 0.0,
    this.usersByCountry = const {},
    this.popularSubjects = const {},
    required this.lastUpdated,
  });

  factory AppStatistics.fromMap(Map<String, dynamic> map) {
    return AppStatistics(
      totalUsers: map['totalUsers'] ?? 0,
      activeUsers: map['activeUsers'] ?? 0,
      newUsersToday: map['newUsersToday'] ?? 0,
      totalQuizzes: map['totalQuizzes'] ?? 0,
      quizzesToday: map['quizzesToday'] ?? 0,
      totalStudyPacks: map['totalStudyPacks'] ?? 0,
      totalFlashcards: map['totalFlashcards'] ?? 0,
      averageSessionTime: (map['averageSessionTime'] ?? 0.0).toDouble(),
      usersByCountry: Map<String, int>.from(map['usersByCountry'] ?? {}),
      popularSubjects: Map<String, int>.from(map['popularSubjects'] ?? {}),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'newUsersToday': newUsersToday,
      'totalQuizzes': totalQuizzes,
      'quizzesToday': quizzesToday,
      'totalStudyPacks': totalStudyPacks,
      'totalFlashcards': totalFlashcards,
      'averageSessionTime': averageSessionTime,
      'usersByCountry': usersByCountry,
      'popularSubjects': popularSubjects,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

// Notification Model
class AdminNotification {
  final String id;
  final String title;
  final String message;
  final String type; // info, warning, error, success
  final List<String> targetUsers; // empty = all users
  final bool isScheduled;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final String createdBy;
  final bool isSent;
  final int deliveredCount;
  final Map<String, dynamic> metadata;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.targetUsers = const [],
    this.isScheduled = false,
    this.scheduledAt,
    required this.createdAt,
    required this.createdBy,
    this.isSent = false,
    this.deliveredCount = 0,
    this.metadata = const {},
  });

  factory AdminNotification.fromMap(Map<String, dynamic> map, String id) {
    return AdminNotification(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'info',
      targetUsers: List<String>.from(map['targetUsers'] ?? []),
      isScheduled: map['isScheduled'] ?? false,
      scheduledAt: map['scheduledAt'] != null 
          ? (map['scheduledAt'] as Timestamp).toDate() 
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      isSent: map['isSent'] ?? false,
      deliveredCount: map['deliveredCount'] ?? 0,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'targetUsers': targetUsers,
      'isScheduled': isScheduled,
      'scheduledAt': scheduledAt != null 
          ? Timestamp.fromDate(scheduledAt!) 
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'isSent': isSent,
      'deliveredCount': deliveredCount,
      'metadata': metadata,
    };
  }
}
