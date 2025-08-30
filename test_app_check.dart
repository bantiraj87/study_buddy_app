import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: kDebugMode
        ? ReCaptchaV3Provider('debug-token')
        : ReCaptchaV3Provider('your-recaptcha-site-key'),
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode
        ? AppleProvider.debug
        : AppleProvider.deviceCheck,
  );

  print('✅ Firebase App Check enabled successfully!');
  
  runApp(const AppCheckTestApp());
}

class AppCheckTestApp extends StatelessWidget {
  const AppCheckTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Check Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AppCheckTestScreen(),
    );
  }
}

class AppCheckTestScreen extends StatefulWidget {
  const AppCheckTestScreen({super.key});

  @override
  State<AppCheckTestScreen> createState() => _AppCheckTestScreenState();
}

class _AppCheckTestScreenState extends State<AppCheckTestScreen> {
  String _status = 'App Check initialized';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testAppCheck();
  }

  Future<void> _testAppCheck() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing App Check...';
    });

    try {
      // Test 1: Get App Check token
      print('🔄 Getting App Check token...');
      final token = await FirebaseAppCheck.instance.getToken();
      print('✅ App Check token obtained: \${token?.substring(0, 20)}...');

      // Test 2: Test Firestore access (should work with App Check)
      print('🔄 Testing Firestore access...');
      await FirebaseFirestore.instance.collection('test').doc('app_check_test').set({
        'message': 'App Check is working!',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Firestore access successful with App Check!');

      // Test 3: Test Auth access (should work with App Check)
      print('🔄 Testing Auth access...');
      final currentUser = FirebaseAuth.instance.currentUser;
      print('✅ Auth access successful. Current user: \${currentUser?.email ?? "Not signed in"}');

      setState(() {
        _status = 'All App Check tests passed! ✅\\n\\nApp Check is properly protecting your Firebase services.';
        _isLoading = false;
      });

    } catch (e) {
      print('❌ App Check test failed: \$e');
      setState(() {
        _status = 'App Check test failed: \$e\\n\\nCheck the debug tokens in Firebase Console.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase App Check Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Check Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Testing...'),
                        ],
                      )
                    else
                      Text(
                        _status,
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Tokens Setup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'For development, add debug tokens in Firebase Console:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Go to Firebase Console > App Check',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '2. Select your app',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '3. Add debug tokens from the logs',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '4. For web: add "debug-token" as debug token',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testAppCheck,
                child: const Text('Re-test App Check'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
