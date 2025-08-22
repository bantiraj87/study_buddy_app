import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String difficulty;
  final List<String> tags;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficulty,
    this.tags = const [],
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map, String id) {
    return QuizQuestion(
      id: id,
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'difficulty': difficulty,
      'tags': tags,
    };
  }
}

class QuizModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String difficulty;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuizQuestion> questions;
  final int timeLimit; // in minutes
  final bool isPublic;
  final bool isRandomOrder;
  final Map<String, dynamic> settings;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.difficulty,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.questions = const [],
    this.timeLimit = 30,
    this.isPublic = false,
    this.isRandomOrder = false,
    this.settings = const {},
  });

  factory QuizModel.fromMap(Map<String, dynamic> map, String id) {
    List<QuizQuestion> questionsList = [];
    if (map['questions'] != null) {
      questionsList = (map['questions'] as List)
          .asMap()
          .entries
          .map((entry) => QuizQuestion.fromMap(
              Map<String, dynamic>.from(entry.value), entry.key.toString()))
          .toList();
    }

    return QuizModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      questions: questionsList,
      timeLimit: map['timeLimit'] ?? 30,
      isPublic: map['isPublic'] ?? false,
      isRandomOrder: map['isRandomOrder'] ?? false,
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'difficulty': difficulty,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimit': timeLimit,
      'isPublic': isPublic,
      'isRandomOrder': isRandomOrder,
      'settings': settings,
    };
  }

  QuizModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? difficulty,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuizQuestion>? questions,
    int? timeLimit,
    bool? isPublic,
    bool? isRandomOrder,
    Map<String, dynamic>? settings,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      questions: questions ?? this.questions,
      timeLimit: timeLimit ?? this.timeLimit,
      isPublic: isPublic ?? this.isPublic,
      isRandomOrder: isRandomOrder ?? this.isRandomOrder,
      settings: settings ?? this.settings,
    );
  }
}

class QuizResult {
  final String id;
  final String quizId;
  final String userId;
  final int score;
  final int totalQuestions;
  final int timeSpent; // in seconds
  final DateTime completedAt;
  final List<int> userAnswers;
  final Map<String, dynamic> analytics;

  QuizResult({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.timeSpent,
    required this.completedAt,
    this.userAnswers = const [],
    this.analytics = const {},
  });

  factory QuizResult.fromMap(Map<String, dynamic> map, String id) {
    return QuizResult(
      id: id,
      quizId: map['quizId'] ?? '',
      userId: map['userId'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timeSpent: map['timeSpent'] ?? 0,
      completedAt: (map['completedAt'] as Timestamp).toDate(),
      userAnswers: List<int>.from(map['userAnswers'] ?? []),
      analytics: Map<String, dynamic>.from(map['analytics'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeSpent': timeSpent,
      'completedAt': Timestamp.fromDate(completedAt),
      'userAnswers': userAnswers,
      'analytics': analytics,
    };
  }

  double get accuracy => totalQuestions > 0 ? score / totalQuestions : 0.0;
}
