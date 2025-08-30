# AI-Powered Study Buddy App

🧠 **AI-Powered Study Buddy App** is an intelligent learning platform that leverages artificial intelligence to enhance your study experience. Built with Flutter and powered by Google Gemini AI, this app provides personalized learning assistance, automated content generation, and comprehensive study management tools.

## ✨ Features

### 🤖 AI-Powered Learning
- **Smart Notes Summarization**: AI-powered content summarization with file upload support
- **Interactive AI Tutor**: Chat-based Q&A system for personalized learning assistance
- **Automated Quiz Generation**: Create quizzes from your study content using AI
- **Flashcard Generation**: AI-generated flashcards with spaced repetition
- **Study Recommendations**: Personalized study suggestions based on your progress

### 📱 Modern Interface
- Beautiful Material 3 design with smooth animations
- Responsive layout that works across different screen sizes
- Intuitive navigation and user-friendly interface
- Dark/light theme support

### 🏆 Competitive Learning
- Competitive quiz system with rankings
- Mock tests and practice sessions
- Study packs for organized learning
- Progress tracking and analytics

### 🛡️ Admin Panel
- Web-based admin interface for content management
- User management and analytics dashboard
- Quiz and study pack creation tools

### 🔄 Auto-Update System
- Seamless app updates without app store dependencies
- Background update checking
- User-friendly update notifications

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0 or later
- Firebase project setup
- Google Gemini API key

### Installation
1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure Firebase (see FIREBASE_SETUP.md)
4. Add your Google Gemini API key
5. Run the app: `flutter run`

## 📚 Documentation

- [Firebase Setup Guide](FIREBASE_SETUP.md)
- [Auto-Update System](AUTO_UPDATE_GUIDE.md)
- [Implementation Details](IMPLEMENTATION_COMPLETE.md)
- [Admin Panel Setup](admin_panel/README.md)

## 🏗️ Architecture

Built with clean architecture principles using:
- **State Management**: Provider pattern
- **Backend**: Firebase (Firestore, Authentication, App Check)
- **AI Integration**: Google Gemini API
- **UI**: Material 3 design system
- **Auto-Updates**: Custom update service
