class StudyPlan {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String difficulty;
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime endDate;
  final List<StudySession> sessions;
  final List<String> goals;
  final Map<String, dynamic> progress;
  final bool isActive;

  StudyPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.difficulty,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.sessions,
    required this.goals,
    required this.progress,
    this.isActive = true,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'difficulty': difficulty,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'sessions': sessions.map((session) => session.toMap()).toList(),
      'goals': goals,
      'progress': progress,
      'isActive': isActive,
    };
  }

  // Create from Map (Firestore)
  factory StudyPlan.fromMap(Map<String, dynamic> map) {
    return StudyPlan(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? 0),
      sessions: (map['sessions'] as List<dynamic>?)
          ?.map((session) => StudySession.fromMap(session))
          .toList() ?? [],
      goals: List<String>.from(map['goals'] ?? []),
      progress: Map<String, dynamic>.from(map['progress'] ?? {}),
      isActive: map['isActive'] ?? true,
    );
  }

  // Copy with updated values
  StudyPlan copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? difficulty,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    List<StudySession>? sessions,
    List<String>? goals,
    Map<String, dynamic>? progress,
    bool? isActive,
  }) {
    return StudyPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sessions: sessions ?? this.sessions,
      goals: goals ?? this.goals,
      progress: progress ?? this.progress,
      isActive: isActive ?? this.isActive,
    );
  }

  // Calculate completion percentage
  double get completionPercentage {
    if (sessions.isEmpty) return 0.0;
    int completedSessions = sessions.where((session) => session.isCompleted).length;
    return (completedSessions / sessions.length) * 100;
  }

  // Get total estimated time
  int get totalEstimatedMinutes {
    return sessions.fold(0, (sum, session) => sum + session.estimatedMinutes);
  }

  // Get completed time
  int get completedMinutes {
    return sessions
        .where((session) => session.isCompleted)
        .fold(0, (sum, session) => sum + session.actualMinutes);
  }
}

class StudySession {
  final String id;
  final String title;
  final String description;
  final String topic;
  final String activityType;
  final int estimatedMinutes;
  final int actualMinutes;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final bool isCompleted;
  final List<String> resources;
  final Map<String, dynamic> notes;

  StudySession({
    required this.id,
    required this.title,
    required this.description,
    required this.topic,
    required this.activityType,
    required this.estimatedMinutes,
    this.actualMinutes = 0,
    required this.scheduledDate,
    this.completedDate,
    this.isCompleted = false,
    this.resources = const [],
    this.notes = const {},
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'topic': topic,
      'activityType': activityType,
      'estimatedMinutes': estimatedMinutes,
      'actualMinutes': actualMinutes,
      'scheduledDate': scheduledDate.millisecondsSinceEpoch,
      'completedDate': completedDate?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'resources': resources,
      'notes': notes,
    };
  }

  // Create from Map (Firestore)
  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      topic: map['topic'] ?? '',
      activityType: map['activityType'] ?? 'study',
      estimatedMinutes: map['estimatedMinutes'] ?? 30,
      actualMinutes: map['actualMinutes'] ?? 0,
      scheduledDate: DateTime.fromMillisecondsSinceEpoch(map['scheduledDate'] ?? 0),
      completedDate: map['completedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedDate'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
      resources: List<String>.from(map['resources'] ?? []),
      notes: Map<String, dynamic>.from(map['notes'] ?? {}),
    );
  }

  // Copy with updated values
  StudySession copyWith({
    String? id,
    String? title,
    String? description,
    String? topic,
    String? activityType,
    int? estimatedMinutes,
    int? actualMinutes,
    DateTime? scheduledDate,
    DateTime? completedDate,
    bool? isCompleted,
    List<String>? resources,
    Map<String, dynamic>? notes,
  }) {
    return StudySession(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      topic: topic ?? this.topic,
      activityType: activityType ?? this.activityType,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      resources: resources ?? this.resources,
      notes: notes ?? this.notes,
    );
  }
}

// Daily Challenge Model
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final String subject;
  final int points;
  final String timeEstimate;
  final String content;
  final DateTime date;
  final bool isCompleted;
  final DateTime? completedAt;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.subject,
    required this.points,
    required this.timeEstimate,
    required this.content,
    required this.date,
    this.isCompleted = false,
    this.completedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'subject': subject,
      'points': points,
      'timeEstimate': timeEstimate,
      'content': content,
      'date': date.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  // Create from Map (Firestore)
  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'study',
      subject: map['subject'] ?? '',
      points: map['points'] ?? 0,
      timeEstimate: map['timeEstimate'] ?? '15 minutes',
      content: map['content'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
    );
  }
}
