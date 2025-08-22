import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardModel {
  final String id;
  final String front;
  final String back;
  final String studyPackId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String difficulty;
  final Map<String, dynamic> metadata;

  FlashcardModel({
    required this.id,
    required this.front,
    required this.back,
    required this.studyPackId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.difficulty = 'Medium',
    this.metadata = const {},
  });

  factory FlashcardModel.fromMap(Map<String, dynamic> map, String id) {
    return FlashcardModel(
      id: id,
      front: map['front'] ?? '',
      back: map['back'] ?? '',
      studyPackId: map['studyPackId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      tags: List<String>.from(map['tags'] ?? []),
      difficulty: map['difficulty'] ?? 'Medium',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'front': front,
      'back': back,
      'studyPackId': studyPackId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'difficulty': difficulty,
      'metadata': metadata,
    };
  }

  FlashcardModel copyWith({
    String? id,
    String? front,
    String? back,
    String? studyPackId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? difficulty,
    Map<String, dynamic>? metadata,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      studyPackId: studyPackId ?? this.studyPackId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      metadata: metadata ?? this.metadata,
    );
  }
}

class FlashcardProgress {
  final String id;
  final String flashcardId;
  final String userId;
  final int timesStudied;
  final int correctAnswers;
  final int totalAttempts;
  final DateTime lastStudied;
  final DateTime nextReview;
  final int confidenceLevel; // 1-5
  final Map<String, dynamic> spicedRepetition; // For spaced repetition algorithm

  FlashcardProgress({
    required this.id,
    required this.flashcardId,
    required this.userId,
    this.timesStudied = 0,
    this.correctAnswers = 0,
    this.totalAttempts = 0,
    required this.lastStudied,
    required this.nextReview,
    this.confidenceLevel = 3,
    this.spicedRepetition = const {},
  });

  factory FlashcardProgress.fromMap(Map<String, dynamic> map, String id) {
    return FlashcardProgress(
      id: id,
      flashcardId: map['flashcardId'] ?? '',
      userId: map['userId'] ?? '',
      timesStudied: map['timesStudied'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalAttempts: map['totalAttempts'] ?? 0,
      lastStudied: (map['lastStudied'] as Timestamp).toDate(),
      nextReview: (map['nextReview'] as Timestamp).toDate(),
      confidenceLevel: map['confidenceLevel'] ?? 3,
      spicedRepetition: Map<String, dynamic>.from(map['spicedRepetition'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flashcardId': flashcardId,
      'userId': userId,
      'timesStudied': timesStudied,
      'correctAnswers': correctAnswers,
      'totalAttempts': totalAttempts,
      'lastStudied': Timestamp.fromDate(lastStudied),
      'nextReview': Timestamp.fromDate(nextReview),
      'confidenceLevel': confidenceLevel,
      'spicedRepetition': spicedRepetition,
    };
  }

  double get accuracy => totalAttempts > 0 ? correctAnswers / totalAttempts : 0.0;
}
