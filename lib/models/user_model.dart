import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  moderator,
  premium,
  regular,
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final int studyStreak;
  final int totalTopicsCompleted;
  final double quizAccuracy;
  final List<String> interests;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> studyStatistics;
  final UserRole role;
  final bool isActive;
  final DateTime? suspendedUntil;
  final List<String> permissions;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.studyStreak = 0,
    this.totalTopicsCompleted = 0,
    this.quizAccuracy = 0.0,
    this.interests = const [],
    this.preferences = const {},
    this.studyStatistics = const {},
    this.role = UserRole.regular,
    this.isActive = true,
    this.suspendedUntil,
    this.permissions = const [],
  });

  // Convert from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp).toDate(),
      studyStreak: map['studyStreak'] ?? 0,
      totalTopicsCompleted: map['totalTopicsCompleted'] ?? 0,
      quizAccuracy: (map['quizAccuracy'] ?? 0).toDouble(),
      interests: List<String>.from(map['interests'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      studyStatistics: Map<String, dynamic>.from(map['studyStatistics'] ?? {}),
      role: _parseUserRole(map['role']),
      isActive: map['isActive'] ?? true,
      suspendedUntil: map['suspendedUntil'] != null 
          ? (map['suspendedUntil'] as Timestamp).toDate() 
          : null,
      permissions: List<String>.from(map['permissions'] ?? []),
    );
  }
  
  static UserRole _parseUserRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'premium':
        return UserRole.premium;
      default:
        return UserRole.regular;
    }
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'studyStreak': studyStreak,
      'totalTopicsCompleted': totalTopicsCompleted,
      'quizAccuracy': quizAccuracy,
      'interests': interests,
      'preferences': preferences,
      'studyStatistics': studyStatistics,
      'role': role.name,
      'isActive': isActive,
      'suspendedUntil': suspendedUntil != null 
          ? Timestamp.fromDate(suspendedUntil!) 
          : null,
      'permissions': permissions,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? studyStreak,
    int? totalTopicsCompleted,
    double? quizAccuracy,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? studyStatistics,
    UserRole? role,
    bool? isActive,
    DateTime? suspendedUntil,
    List<String>? permissions,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      studyStreak: studyStreak ?? this.studyStreak,
      totalTopicsCompleted: totalTopicsCompleted ?? this.totalTopicsCompleted,
      quizAccuracy: quizAccuracy ?? this.quizAccuracy,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      studyStatistics: studyStatistics ?? this.studyStatistics,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
      permissions: permissions ?? this.permissions,
    );
  }
  
  // Helper methods for admin functionality
  bool get isAdmin => role == UserRole.admin;
  bool get isModerator => role == UserRole.moderator;
  bool get isPremium => role == UserRole.premium;
  bool get hasAdminPrivileges => role == UserRole.admin || role == UserRole.moderator;
  
  // Compatibility getter for admin screens
  String? get profileImageUrl => photoUrl;
  
  bool hasPermission(String permission) {
    return permissions.contains(permission) || isAdmin;
  }
  
  bool get isSuspended {
    if (suspendedUntil == null) return false;
    return DateTime.now().isBefore(suspendedUntil!);
  }
}
