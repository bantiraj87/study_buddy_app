import 'package:cloud_firestore/cloud_firestore.dart';

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
    );
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
    );
  }
}
