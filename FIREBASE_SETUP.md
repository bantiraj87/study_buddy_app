# Firebase Setup Guide for Study Buddy App

## Current Status ✅
- ✅ Firebase Core configuration is set up correctly
- ✅ Google Services plugin is properly configured
- ✅ App builds and runs successfully
- ✅ Firebase initialization works

## Issues to Fix ❌

### 1. Enable Firebase Services in Console
Your Firebase project `study-buddy-dedde` needs the following services enabled:

#### Firestore Database
1. Go to: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=study-buddy-dedde
2. Click "Enable API"
3. Then go to Firebase Console → Firestore Database
4. Click "Create database"
5. Choose "Start in test mode" for development

#### Firebase Authentication
1. Go to Firebase Console → Authentication
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Anonymous" authentication (for testing)
5. Enable "Email/Password" authentication

#### Firebase Analytics (Optional)
1. Go to Firebase Console → Analytics
2. Click "Enable Google Analytics"

### 2. Update google-services.json
After enabling services:
1. Go to Firebase Console → Project Settings → General tab
2. Scroll down to "Your apps"
3. Click the Android app
4. Click "Download google-services.json"
5. Replace the file in `android/app/google-services.json`

### 3. Test Firebase Connection
After completing the above steps, you can test the connection by temporarily changing `main.dart`:

```dart
// Change this line in main.dart:
home: const AuthWrapper(),
// To this line:
home: const FirebaseConnectionTest(),
```

Then run: `flutter run --debug`

### 4. Firestore Security Rules
Add basic security rules in Firestore Console → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow test documents for development
    match /test/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Current Firebase Configuration
Your project is configured with:
- **Project ID**: `study-buddy-dedde`
- **API Key**: `AIzaSyCMW128ZxXUS6jVRriL0yXGVfVn900tvh4`
- **App ID**: `1:428716404868:android:746b021d72f6b711ed92d1`
- **Storage Bucket**: `study-buddy-dedde.firebasestorage.app`

## Troubleshooting Common Issues

### Network Connection Issues
If you see DNS resolution errors:
1. Check your internet connection
2. Try switching between WiFi and mobile data
3. Restart your device

### Build Issues
If you encounter build problems:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### Gradle Daemon Issues
If Gradle fails to start:
```bash
cd android
./gradlew --stop
cd ..
flutter clean
```

## Next Steps After Setup
1. Enable all required Firebase services
2. Download fresh google-services.json
3. Test connection using FirebaseConnectionTest
4. Configure security rules
5. Test authentication and Firestore operations

## Contact Firebase Support
If issues persist, you can:
1. Check Firebase Console status page
2. Review Firebase documentation
3. Post in Firebase GitHub issues
4. Use Firebase support in Google Cloud Console
