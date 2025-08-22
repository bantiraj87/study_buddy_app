import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

class FirebaseDiagnostic {
  static Future<void> runDiagnostic() async {
    developer.log('🔥 Starting Firebase Diagnostic...');
    
    try {
      // Test Firebase Core initialization
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      developer.log('✅ Firebase Core initialized successfully');
      
      // Test Firebase Auth
      try {
        FirebaseAuth auth = FirebaseAuth.instance;
        developer.log('✅ Firebase Auth instance created');
        
        // Try anonymous sign-in
        UserCredential userCredential = await auth.signInAnonymously();
        developer.log('✅ Anonymous authentication successful');
        developer.log('User UID: ${userCredential.user?.uid}');
        
      } catch (authError) {
        developer.log('❌ Firebase Auth Error: $authError');
      }
      
      // Test Firestore connection
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        developer.log('✅ Firestore instance created');
        
        // Try to write a test document
        await firestore.collection('diagnostic').doc('test').set({
          'timestamp': FieldValue.serverTimestamp(),
          'message': 'Firebase diagnostic test'
        });
        developer.log('✅ Firestore write successful');
        
      } catch (firestoreError) {
        developer.log('❌ Firestore Error: $firestoreError');
      }
      
    } catch (coreError) {
      developer.log('❌ Firebase Core Error: $coreError');
    }
    
    developer.log('🏁 Firebase Diagnostic Complete');
  }
}
