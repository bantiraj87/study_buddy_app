import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_pack_model.dart';
import '../models/quiz_model.dart';
import '../models/flashcard_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file to Firebase Storage and return the download URL
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading file: $e');
      rethrow;
    }
  }

  // Study Packs CRUD Operations
  Future<List<StudyPackModel>> getTrendingStudyPacks() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('study_packs')
          .where('isTrending', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .orderBy('downloads', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => StudyPackModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting trending study packs: $e');
      return [];
    }
  }

  Future<List<StudyPackModel>> getUserStudyPacks(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('study_packs')
          .where('createdBy', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StudyPackModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user study packs: $e');
      return [];
    }
  }

  Future<String> createStudyPack(StudyPackModel studyPack) async {
    try {
      DocumentReference ref = await _firestore
          .collection('study_packs')
          .add(studyPack.toMap());
      return ref.id;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating study pack: $e');
      rethrow;
    }
  }

  Future<void> updateStudyPack(String id, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('study_packs')
          .doc(id)
          .update(data);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating study pack: $e');
      rethrow;
    }
  }

  Future<void> deleteStudyPack(String id) async {
    try {
      await _firestore
          .collection('study_packs')
          .doc(id)
          .delete();
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting study pack: $e');
      rethrow;
    }
  }


  // User CRUD Operations
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      // ignore: avoid_print
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Quiz CRUD Operations
  Future<List<QuizModel>> getPublicQuizzes() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting public quizzes: $e');
      return [];
    }
  }

  Future<List<QuizModel>> getUserQuizzes(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .where('createdBy', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user quizzes: $e');
      return [];
    }
  }

  Future<QuizModel?> getQuiz(String quizId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('quizzes')
          .doc(quizId)
          .get();

      if (doc.exists) {
        return QuizModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting quiz: $e');
      return null;
    }
  }

  Future<String> createQuiz(QuizModel quiz) async {
    try {
      DocumentReference ref = await _firestore
          .collection('quizzes')
          .add(quiz.toMap());
      return ref.id;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating quiz: $e');
      rethrow;
    }
  }

  Future<void> updateQuiz(String id, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(id)
          .update(data);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating quiz: $e');
      rethrow;
    }
  }

  // Quiz Result Operations
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      await _firestore
          .collection('quiz_results')
          .add(result.toMap());
    } catch (e) {
      // ignore: avoid_print
      print('Error saving quiz result: $e');
      rethrow;
    }
  }

  Future<List<QuizResult>> getUserQuizResults(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => QuizResult.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user quiz results: $e');
      return [];
    }
  }

  // Flashcard CRUD Operations
  Future<List<FlashcardModel>> getFlashcards(String studyPackId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('flashcards')
          .where('studyPackId', isEqualTo: studyPackId)
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => FlashcardModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting flashcards: $e');
      return [];
    }
  }

  Future<String> createFlashcard(FlashcardModel flashcard) async {
    try {
      DocumentReference ref = await _firestore
          .collection('flashcards')
          .add(flashcard.toMap());
      return ref.id;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating flashcard: $e');
      rethrow;
    }
  }

  Future<void> updateFlashcard(String id, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('flashcards')
          .doc(id)
          .update(data);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating flashcard: $e');
      rethrow;
    }
  }

  Future<void> deleteFlashcard(String id) async {
    try {
      await _firestore
          .collection('flashcards')
          .doc(id)
          .delete();
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting flashcard: $e');
      rethrow;
    }
  }

  // Flashcard Progress Operations
  Future<FlashcardProgress?> getFlashcardProgress(String flashcardId, String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('flashcard_progress')
          .where('flashcardId', isEqualTo: flashcardId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return FlashcardProgress.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>,
            snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting flashcard progress: $e');
      return null;
    }
  }

  Future<void> updateFlashcardProgress(FlashcardProgress progress) async {
    try {
      await _firestore
          .collection('flashcard_progress')
          .doc(progress.id)
          .set(progress.toMap());
    } catch (e) {
      // ignore: avoid_print
      print('Error updating flashcard progress: $e');
      rethrow;
    }
  }

  // Search Operations
  Future<List<StudyPackModel>> searchStudyPacks(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('study_packs')
          .where('isPublic', isEqualTo: true)
          .get();

      // Client-side filtering for text search
      return snapshot.docs
          .map((doc) => StudyPackModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .where((pack) =>
              pack.title.toLowerCase().contains(query.toLowerCase()) ||
              pack.description.toLowerCase().contains(query.toLowerCase()) ||
              pack.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error searching study packs: $e');
      return [];
    }
  }
}
