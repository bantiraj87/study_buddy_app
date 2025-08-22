import 'package:flutter/foundation.dart';
import '../models/study_pack_model.dart';
import '../models/quiz_model.dart';
import '../models/flashcard_model.dart';
import '../services/database_service.dart';

class StudyProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // Study Packs
  List<StudyPackModel> _trendingStudyPacks = [];
  List<StudyPackModel> _userStudyPacks = [];

  // Quizzes
  List<QuizModel> _publicQuizzes = [];
  List<QuizModel> _userQuizzes = [];
  QuizModel? _currentQuiz;

  // Flashcards
  List<FlashcardModel> _currentFlashcards = [];

  // State
  bool _isLoading = false;
  String? _error;

  // Getters
  List<StudyPackModel> get trendingStudyPacks => _trendingStudyPacks;
  List<StudyPackModel> get userStudyPacks => _userStudyPacks;
  List<QuizModel> get publicQuizzes => _publicQuizzes;
  List<QuizModel> get userQuizzes => _userQuizzes;
  QuizModel? get currentQuiz => _currentQuiz;
  List<FlashcardModel> get currentFlashcards => _currentFlashcards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Study Packs Methods
  Future<void> loadTrendingStudyPacks() async {
    try {
      _setLoading(true);
      _setError(null);

      _trendingStudyPacks = await _databaseService.getTrendingStudyPacks();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load trending study packs: $e');
    }
  }

  Future<void> loadUserStudyPacks(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      _userStudyPacks = await _databaseService.getUserStudyPacks(userId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load user study packs: $e');
    }
  }

  Future<bool> createStudyPack(StudyPackModel studyPack) async {
    try {
      _setLoading(true);
      _setError(null);

      final id = await _databaseService.createStudyPack(studyPack);
      final createdStudyPack = studyPack.copyWith(id: id);
      
      _userStudyPacks.insert(0, createdStudyPack);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to create study pack: $e');
      return false;
    }
  }

  Future<bool> updateStudyPack(String id, Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.updateStudyPack(id, data);
      
      // Update local list
      final index = _userStudyPacks.indexWhere((pack) => pack.id == id);
      if (index != -1) {
        // You might want to reload the specific study pack here
        // For now, just trigger a refresh
        notifyListeners();
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update study pack: $e');
      return false;
    }
  }

  Future<bool> deleteStudyPack(String id) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.deleteStudyPack(id);
      
      // Remove from local list
      _userStudyPacks.removeWhere((pack) => pack.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to delete study pack: $e');
      return false;
    }
  }

  // Quiz Methods
  Future<void> loadPublicQuizzes() async {
    try {
      _setLoading(true);
      _setError(null);

      _publicQuizzes = await _databaseService.getPublicQuizzes();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load public quizzes: $e');
    }
  }

  Future<void> loadUserQuizzes(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      _userQuizzes = await _databaseService.getUserQuizzes(userId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load user quizzes: $e');
    }
  }

  Future<void> loadQuiz(String quizId) async {
    try {
      _setLoading(true);
      _setError(null);

      _currentQuiz = await _databaseService.getQuiz(quizId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load quiz: $e');
    }
  }

  Future<bool> createQuiz(QuizModel quiz) async {
    try {
      _setLoading(true);
      _setError(null);

      final id = await _databaseService.createQuiz(quiz);
      final createdQuiz = quiz.copyWith(id: id);
      
      _userQuizzes.insert(0, createdQuiz);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to create quiz: $e');
      return false;
    }
  }

  Future<bool> updateQuiz(String id, Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.updateQuiz(id, data);
      
      // Update local list if needed
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update quiz: $e');
      return false;
    }
  }

  Future<bool> saveQuizResult(QuizResult result) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.saveQuizResult(result);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to save quiz result: $e');
      return false;
    }
  }

  // Flashcard Methods
  Future<void> loadFlashcards(String studyPackId) async {
    try {
      _setLoading(true);
      _setError(null);

      _currentFlashcards = await _databaseService.getFlashcards(studyPackId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load flashcards: $e');
    }
  }

  Future<bool> createFlashcard(FlashcardModel flashcard) async {
    try {
      _setLoading(true);
      _setError(null);

      final id = await _databaseService.createFlashcard(flashcard);
      final createdFlashcard = flashcard.copyWith(id: id);
      
      _currentFlashcards.add(createdFlashcard);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to create flashcard: $e');
      return false;
    }
  }

  Future<bool> updateFlashcard(String id, Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.updateFlashcard(id, data);
      
      // Update local list
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update flashcard: $e');
      return false;
    }
  }

  Future<bool> deleteFlashcard(String id) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.deleteFlashcard(id);
      
      // Remove from local list
      _currentFlashcards.removeWhere((card) => card.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to delete flashcard: $e');
      return false;
    }
  }

  // Search Methods
  Future<List<StudyPackModel>> searchStudyPacks(String query) async {
    try {
      _setLoading(true);
      _setError(null);

      final results = await _databaseService.searchStudyPacks(query);
      _setLoading(false);
      return results;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to search study packs: $e');
      return [];
    }
  }

  // Utility Methods
  List<StudyPackModel> getStudyPacksBySubject(String subject) {
    return _trendingStudyPacks
        .where((pack) => pack.subject.toLowerCase() == subject.toLowerCase())
        .toList();
  }

  List<QuizModel> getQuizzesByDifficulty(String difficulty) {
    return _publicQuizzes
        .where((quiz) => quiz.difficulty.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }

  void clearCurrentQuiz() {
    _currentQuiz = null;
    notifyListeners();
  }

  void clearCurrentFlashcards() {
    _currentFlashcards = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAllData(String userId) async {
    await Future.wait([
      loadTrendingStudyPacks(),
      loadUserStudyPacks(userId),
      loadPublicQuizzes(),
      loadUserQuizzes(userId),
    ]);
  }
}
