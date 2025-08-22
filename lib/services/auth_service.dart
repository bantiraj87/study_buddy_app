import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      if (credential.user != null) {
        await _updateLastLogin(credential.user!.uid);
      }
      
      return credential;
    } catch (e) {
      // ignore: avoid_print
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!, name);
      }

      return credential;
    } catch (e) {
      // ignore: avoid_print
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // ignore: avoid_print
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String name) async {
    try {
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: name,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        studyStreak: 0,
        totalTopicsCompleted: 0,
        quizAccuracy: 0.0,
        interests: [],
        preferences: {},
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());
    } catch (e) {
      // ignore: avoid_print
      print('Error creating user document: $e');
      rethrow;
    }
  }

  // Update last login time
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'lastLoginAt': Timestamp.now()});
    } catch (e) {
      // ignore: avoid_print
      print('Error updating last login: $e');
    }
  }

  // Get user document from Firestore
  Future<UserModel?> getUserDocument(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user document: $e');
      return null;
    }
  }

  // Update user document
  Future<void> updateUserDocument(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update(data);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating user document: $e');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // ignore: avoid_print
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Create or update user document
      if (userCredential.user != null) {
        await _createOrUpdateUserDocument(
          userCredential.user!, 
          userCredential.user!.displayName ?? 'User',
        );
        await _updateLastLogin(userCredential.user!.uid);
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  // Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Google Sign-Out error: $e');
      rethrow;
    }
  }

  // Create or update user document (for Google Sign-In)
  Future<void> _createOrUpdateUserDocument(User user, String name) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // Create new user document
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: name,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          studyStreak: 0,
          totalTopicsCompleted: 0,
          quizAccuracy: 0.0,
          interests: [],
          preferences: {},
        );
        
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      } else {
        // Update existing user document with latest info
        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
          'photoUrl': user.photoURL,
          'email': user.email ?? '',
          'lastLoginAt': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('Error creating/updating user document: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user from Firebase Auth
        await user.delete();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
