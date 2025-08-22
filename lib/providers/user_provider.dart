import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../services/database_service.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  UserModel? _currentUser;
  List<QuizResult> _userQuizResults = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<QuizResult> get userQuizResults => _userQuizResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // User statistics
  int get totalQuizzesCompleted => _userQuizResults.length;
  double get averageQuizScore {
    if (_userQuizResults.isEmpty) return 0.0;
    return _userQuizResults
        .map((result) => result.accuracy)
        .reduce((a, b) => a + b) / _userQuizResults.length;
  }

  // Set current user
  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      _loadUserData();
    } else {
      _clearUserData();
    }
    notifyListeners();
  }

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

  // Clear user data
  void _clearUserData() {
    _userQuizResults = [];
    _error = null;
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      _setLoading(true);
      _setError(null);

      // Load quiz results
      _userQuizResults = await _databaseService.getUserQuizResults(_currentUser!.id);
      
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load user data: $e');
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    await _loadUserData();
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? photoUrl,
    List<String>? interests,
    Map<String, dynamic>? preferences,
  }) async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);
      _setError(null);

      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        interests: interests ?? _currentUser!.interests,
        preferences: preferences ?? _currentUser!.preferences,
      );

      // Save to Firestore
      await _databaseService.updateUser(updatedUser);
      
      _currentUser = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update profile: $e');
      return false;
    }
  }

  // Update study streak
  Future<void> updateStudyStreak() async {
    if (_currentUser == null) return;

    final now = DateTime.now();
    final lastLogin = _currentUser!.lastLoginAt;
    final daysSinceLastLogin = now.difference(lastLogin).inDays;

    int newStreak = _currentUser!.studyStreak;

    if (daysSinceLastLogin == 1) {
      // Consecutive day - increment streak
      newStreak++;
    } else if (daysSinceLastLogin > 1) {
      // Streak broken - reset to 1
      newStreak = 1;
    }
    // If daysSinceLastLogin == 0, keep the same streak

    _currentUser = _currentUser!.copyWith(
      studyStreak: newStreak,
      lastLoginAt: now,
    );
    
    notifyListeners();
  }

  // Update quiz accuracy after completing a quiz
  Future<void> updateQuizAccuracy(double newAccuracy) async {
    if (_currentUser == null) return;

    final currentAccuracy = _currentUser!.quizAccuracy;
    final totalQuizzes = totalQuizzesCompleted + 1;
    
    // Calculate weighted average
    final updatedAccuracy = ((currentAccuracy * totalQuizzesCompleted) + newAccuracy) / totalQuizzes;

    _currentUser = _currentUser!.copyWith(
      quizAccuracy: updatedAccuracy,
    );

    notifyListeners();
  }

  // Increment completed topics
  Future<void> incrementCompletedTopics() async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      totalTopicsCompleted: _currentUser!.totalTopicsCompleted + 1,
    );

    notifyListeners();
  }

  // Add quiz result
  void addQuizResult(QuizResult result) {
    _userQuizResults.insert(0, result); // Add to beginning for recent first
    updateQuizAccuracy(result.accuracy);
    notifyListeners();
  }

  // Get recent quiz results
  List<QuizResult> getRecentQuizResults({int limit = 10}) {
    return _userQuizResults.take(limit).toList();
  }

  // Get quiz results by subject
  List<QuizResult> getQuizResultsBySubject(String subject) {
    return _userQuizResults
        .where((result) => result.analytics['subject'] == subject)
        .toList();
  }

  // Get study statistics for dashboard
  Map<String, dynamic> getStudyStatistics() {
    return {
      'studyStreak': _currentUser?.studyStreak ?? 0,
      'totalTopicsCompleted': _currentUser?.totalTopicsCompleted ?? 0,
      'quizAccuracy': (_currentUser?.quizAccuracy ?? 0.0) * 100,
      'totalQuizzes': totalQuizzesCompleted,
      'averageScore': averageQuizScore * 100,
      'totalStudyTime': _calculateTotalStudyTime(),
    };
  }

  // Calculate total study time from quiz results
  int _calculateTotalStudyTime() {
    return _userQuizResults
        .map((result) => result.timeSpent)
        .fold(0, (total, time) => total + time);
  }

  // Increment summaries generated
  Future<void> incrementSummariesGenerated() async {
    if (_currentUser == null) return;

    final currentStats = _currentUser!.studyStatistics;
    final updatedStats = Map<String, dynamic>.from(currentStats);
    updatedStats['summariesGenerated'] = (updatedStats['summariesGenerated'] ?? 0) + 1;
    
    _currentUser = _currentUser!.copyWith(
      studyStatistics: updatedStats,
    );

    notifyListeners();
  }

  // Increment questions asked
  Future<void> incrementQuestionsAsked() async {
    if (_currentUser == null) return;

    final currentStats = _currentUser!.studyStatistics;
    final updatedStats = Map<String, dynamic>.from(currentStats);
    updatedStats['questionsAsked'] = (updatedStats['questionsAsked'] ?? 0) + 1;
    
    _currentUser = _currentUser!.copyWith(
      studyStatistics: updatedStats,
    );

    notifyListeners();
  }

  // Increment flashcards created
  Future<void> incrementFlashcardsCreated(int count) async {
    if (_currentUser == null) return;

    final currentStats = _currentUser!.studyStatistics;
    final updatedStats = Map<String, dynamic>.from(currentStats);
    updatedStats['flashcardsCreated'] = (updatedStats['flashcardsCreated'] ?? 0) + count;
    
    _currentUser = _currentUser!.copyWith(
      studyStatistics: updatedStats,
    );

    notifyListeners();
  }

  // Add study session time
  Future<void> addStudyTime(int minutes) async {
    if (_currentUser == null) return;

    final currentStats = _currentUser!.studyStatistics;
    final updatedStats = Map<String, dynamic>.from(currentStats);
    updatedStats['totalStudyTime'] = (updatedStats['totalStudyTime'] ?? 0) + minutes;
    
    _currentUser = _currentUser!.copyWith(
      studyStatistics: updatedStats,
    );

    notifyListeners();
  }

  // Increment quizzes generated
  Future<void> incrementQuizzesGenerated() async {
    if (_currentUser == null) return;

    final currentStats = _currentUser!.studyStatistics;
    final updatedStats = Map<String, dynamic>.from(currentStats);
    updatedStats['quizzesGenerated'] = (updatedStats['quizzesGenerated'] ?? 0) + 1;
    
    _currentUser = _currentUser!.copyWith(
      studyStatistics: updatedStats,
    );

    notifyListeners();
  }

  // Increment flashcards generated
  Future<void> incrementFlashcardsGenerated() async {
    if (_currentUser == null) return;

    final currentStats = _currentUser!.studyStatistics;
    final updatedStats = Map<String, dynamic>.from(currentStats);
    updatedStats['flashcardsGenerated'] = (updatedStats['flashcardsGenerated'] ?? 0) + 1;
    
    _currentUser = _currentUser!.copyWith(
      studyStatistics: updatedStats,
    );

    notifyListeners();
  }

  // Upload profile photo to Firebase Storage
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if file exists and is readable
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      // Check file size (limit to 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Image file too large (max 5MB)');
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'max-age=60',
      );
      
      final uploadTask = storageRef.putFile(imageFile, metadata);
      
      // Monitor upload progress if needed
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Profile photo uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error uploading photo: ${e.code} - ${e.message}');
      throw Exception('Firebase storage error: ${e.message}');
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  // Upload profile photo from bytes (for web platform)
  Future<String> uploadProfilePhotoFromBytes(Uint8List imageBytes, String fileName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check file size (limit to 5MB)
      if (imageBytes.length > 5 * 1024 * 1024) {
        throw Exception('Image file too large (max 5MB)');
      }

      // Get file extension from fileName or default to jpg
      final extension = fileName.toLowerCase().contains('.') 
          ? fileName.split('.').last 
          : 'jpg';
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$extension');

      // Upload the bytes with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'max-age=60',
      );
      
      final uploadTask = storageRef.putData(imageBytes, metadata);
      
      // Monitor upload progress if needed
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Profile photo uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error uploading photo: ${e.code} - ${e.message}');
      throw Exception('Firebase storage error: ${e.message}');
    } catch (e) {
      debugPrint('Error uploading profile photo from bytes: $e');
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  // Clear invalid photo URL
  Future<void> clearInvalidPhotoUrl() async {
    if (_currentUser?.photoUrl != null) {
      debugPrint('Clearing invalid photo URL: ${_currentUser!.photoUrl}');
      await updateProfile(photoUrl: null);
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
