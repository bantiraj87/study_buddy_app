# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Study Buddy App is an AI-powered learning platform built with Flutter and Firebase. It provides students with flashcards, quiz generation, AI tutoring, note summarization, and study planning features. The app uses Google's Gemini AI for content generation and Firebase for backend services.

## Essential Development Commands

### Setup and Installation
```bash
# Install Flutter dependencies
flutter pub get

# Clean build cache (when facing build issues)
flutter clean && flutter pub get

# Check Flutter doctor for setup issues
flutter doctor
```

### Building and Running
```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Build APK for Android
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Run on specific device
flutter devices
flutter run -d <device_id>
```

### Testing
```bash
# Run all tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run specific test file
flutter test test/

# Generate test coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code according to Dart style
dart format lib/ test/ --set-exit-if-changed

# Check for unused dependencies
flutter pub deps
```

### Firebase Commands
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules --project study-buddy-dedde

# Deploy using the Windows batch script
.\deploy_firestore_rules.bat

# Test Firebase connection
flutter run --dart-define="FIREBASE_TEST=true"
```

## Code Architecture

### Directory Structure
- **`lib/`** - Main application code
  - **`constants/`** - App-wide constants (themes, strings, colors)
  - **`models/`** - Data models (User, StudyPack, Quiz, Flashcard, StudyPlan)
  - **`providers/`** - State management with Provider pattern
  - **`services/`** - Business logic and external service integrations
  - **`screens/`** - UI screens organized by feature
  - **`widgets/`** - Reusable UI components
  - **`l10n/`** - Localization/internationalization

### Key Services
- **`AIService`** - Google Gemini AI integration for content generation
- **`DatabaseService`** - Firebase Firestore operations (CRUD for all models)
- **`AuthService`** - Firebase Authentication (email/password, Google Sign-in)
- **`UpdateService`** - In-app update management via GitHub releases

### State Management Pattern
The app uses Provider pattern with these key providers:
- **`AuthProvider`** - Authentication state and user session
- **`UserProvider`** - User profile and preferences
- **`StudyProvider`** - Study content and progress tracking
- **`ThemeProvider`** - App theming and localization

### Firebase Integration
- **Project ID**: `study-buddy-dedde`
- **Collections**: `users`, `study_packs`, `quizzes`, `flashcards`
- **Authentication**: Email/password, Google Sign-in
- **Storage**: Firebase Storage for file uploads
- **App Check**: Enabled for API protection

## Important Configuration Files

- **`pubspec.yaml`** - Dependencies and app metadata
- **`firebase.json`** - Firebase project configuration
- **`firestore.rules`** - Database security rules
- **`android/build.gradle.kts`** - Android build configuration
- **`lib/firebase_options.dart`** - Firebase SDK configuration (auto-generated)

## Development Workflow

### Adding New Features
1. Create model in `lib/models/` if data structure is needed
2. Add service methods in appropriate service file
3. Update provider if state management is required
4. Create UI screens in `lib/screens/`
5. Add reusable widgets in `lib/widgets/`
6. Update navigation in `auth_wrapper.dart` or relevant screen

### AI Features Development
- All AI functionality uses `AIService` with Google Gemini
- API key is currently hardcoded (should be moved to environment variables)
- AI responses are parsed as JSON for structured data (quizzes, flashcards)
- Error handling includes fallbacks for AI service failures

### Firebase Data Flow
- Authentication flows through `AuthProvider` → `AuthService` → Firebase Auth
- Database operations go through `DatabaseService` → Firestore
- File uploads use Firebase Storage via `DatabaseService.uploadFile()`
- Real-time listeners can be added in providers for live data updates

### Testing and Firebase
- Use `lib/test_firebase_connection.dart` to verify Firebase setup
- Test authentication with `firebase_auth` in debug mode
- Firebase Emulator Suite can be used for local development
- App Check is configured for production security

### Common Issues and Solutions

**Firebase Permission Errors:**
```bash
# Deploy updated Firestore rules
.\deploy_firestore_rules.bat
```

**Build Issues:**
```bash
# Clear cache and rebuild
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
```

**AI Service Issues:**
- Check Google Gemini API key validity
- Verify internet connectivity
- Review API usage quotas in Google Cloud Console

### App Updates and Distribution
- Version management in `pubspec.yaml` (format: `version: 1.0.1+2`)
- In-app updates via GitHub releases using `UpdateService`
- Google Play Store distribution recommended for production
- APK builds available for direct distribution

## Important Notes

- The app requires Firebase project setup with Firestore, Authentication, and Storage enabled
- Google Gemini AI API key needs to be configured for AI features
- App Check debug tokens are used in development mode
- The project uses latest Firebase SDK versions (v6.x) 
- Material Design 3 theming is implemented throughout the app
