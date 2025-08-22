import 'package:cloud_firestore/cloud_firestore.dart';

class StudyPackModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String difficulty;
  final String thumbnailUrl;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalCards;
  final int totalQuestions;
  final List<String> tags;
  final bool isPublic;
  final bool isTrending;
  final double rating;
  final int downloads;
  final Map<String, dynamic> metadata;

  StudyPackModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.difficulty,
    required this.thumbnailUrl,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.totalCards = 0,
    this.totalQuestions = 0,
    this.tags = const [],
    this.isPublic = false,
    this.isTrending = false,
    this.rating = 0.0,
    this.downloads = 0,
    this.metadata = const {},
  });

  factory StudyPackModel.fromMap(Map<String, dynamic> map, String id) {
    return StudyPackModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      difficulty: map['difficulty'] ?? 'Beginner',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      totalCards: map['totalCards'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      isPublic: map['isPublic'] ?? false,
      isTrending: map['isTrending'] ?? false,
      rating: (map['rating'] ?? 0).toDouble(),
      downloads: map['downloads'] ?? 0,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'difficulty': difficulty,
      'thumbnailUrl': thumbnailUrl,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'totalCards': totalCards,
      'totalQuestions': totalQuestions,
      'tags': tags,
      'isPublic': isPublic,
      'isTrending': isTrending,
      'rating': rating,
      'downloads': downloads,
      'metadata': metadata,
    };
  }

  StudyPackModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? difficulty,
    String? thumbnailUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalCards,
    int? totalQuestions,
    List<String>? tags,
    bool? isPublic,
    bool? isTrending,
    double? rating,
    int? downloads,
    Map<String, dynamic>? metadata,
  }) {
    return StudyPackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalCards: totalCards ?? this.totalCards,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      isTrending: isTrending ?? this.isTrending,
      rating: rating ?? this.rating,
      downloads: downloads ?? this.downloads,
      metadata: metadata ?? this.metadata,
    );
  }
}
