import 'package:flutter/material.dart';

enum DifficultyLevel {
  beginner('Beginner', Colors.green),
  intermediate('Intermediate', Colors.orange),
  advanced('Advanced', Colors.red);

  const DifficultyLevel(this.displayName, this.color);
  final String displayName;
  final Color color;
}

class StudyPack {
  final String id;
  final String title;
  final String subject;
  final String description;
  final DifficultyLevel difficulty;
  final int cardCount;
  final DateTime createdAt;
  final DateTime lastStudied;
  final double progress; // 0.0 to 1.0
  final bool isFavorite;

  StudyPack({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.difficulty,
    required this.cardCount,
    required this.createdAt,
    required this.lastStudied,
    this.progress = 0.0,
    this.isFavorite = false,
  });

  StudyPack copyWith({
    String? id,
    String? title,
    String? subject,
    String? description,
    DifficultyLevel? difficulty,
    int? cardCount,
    DateTime? createdAt,
    DateTime? lastStudied,
    double? progress,
    bool? isFavorite,
  }) {
    return StudyPack(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      cardCount: cardCount ?? this.cardCount,
      createdAt: createdAt ?? this.createdAt,
      lastStudied: lastStudied ?? this.lastStudied,
      progress: progress ?? this.progress,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Convert StudyPack to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'description': description,
      'difficulty': difficulty.name,
      'cardCount': cardCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastStudied': lastStudied.millisecondsSinceEpoch,
      'progress': progress,
      'isFavorite': isFavorite,
    };
  }

  // Create StudyPack from Map (Firebase data)
  static StudyPack fromMap(Map<String, dynamic> map) {
    return StudyPack(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      difficulty: DifficultyLevel.values.firstWhere(
        (level) => level.name == map['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      cardCount: map['cardCount'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastStudied: DateTime.fromMillisecondsSinceEpoch(map['lastStudied'] ?? 0),
      progress: (map['progress'] ?? 0.0).toDouble(),
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}

// Sample data for testing
class StudyPackData {
  static List<StudyPack> samplePacks = [
    StudyPack(
      id: '1',
      title: 'Basic Math Operations',
      subject: 'Mathematics',
      description: 'Learn addition, subtraction, multiplication, and division',
      difficulty: DifficultyLevel.beginner,
      cardCount: 25,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      lastStudied: DateTime.now().subtract(const Duration(days: 2)),
      progress: 0.6,
      isFavorite: true,
    ),
    StudyPack(
      id: '2',
      title: 'English Vocabulary',
      subject: 'English',
      description: 'Essential vocabulary words for daily communication',
      difficulty: DifficultyLevel.intermediate,
      cardCount: 50,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastStudied: DateTime.now().subtract(const Duration(days: 1)),
      progress: 0.3,
      isFavorite: false,
    ),
    StudyPack(
      id: '3',
      title: 'Chemistry Formulas',
      subject: 'Science',
      description: 'Important chemical formulas and equations',
      difficulty: DifficultyLevel.advanced,
      cardCount: 40,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      lastStudied: DateTime.now().subtract(const Duration(days: 3)),
      progress: 0.8,
      isFavorite: true,
    ),
    StudyPack(
      id: '4',
      title: 'World History Timeline',
      subject: 'History',
      description: 'Key historical events and dates',
      difficulty: DifficultyLevel.intermediate,
      cardCount: 35,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      lastStudied: DateTime.now().subtract(const Duration(days: 5)),
      progress: 0.4,
      isFavorite: false,
    ),
    StudyPack(
      id: '5',
      title: 'Spanish Verbs',
      subject: 'Spanish',
      description: 'Common Spanish verbs and conjugations',
      difficulty: DifficultyLevel.beginner,
      cardCount: 30,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      lastStudied: DateTime.now().subtract(const Duration(days: 1)),
      progress: 0.7,
      isFavorite: true,
    ),
    StudyPack(
      id: '6',
      title: 'Physics Laws',
      subject: 'Science',
      description: 'Fundamental laws and principles of physics',
      difficulty: DifficultyLevel.advanced,
      cardCount: 20,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      lastStudied: DateTime.now().subtract(const Duration(days: 4)),
      progress: 0.2,
      isFavorite: false,
    ),
  ];

  static List<String> get subjects {
    return samplePacks.map((pack) => pack.subject).toSet().toList()..sort();
  }
}
