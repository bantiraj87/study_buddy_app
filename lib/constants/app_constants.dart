import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary Colors
  static const Color secondary = Color(0xFFEC4899);
  static const Color secondaryLight = Color(0xFFF472B6);
  static const Color secondaryDark = Color(0xDBE91E63);

  // Accent Colors
  static const Color accent1 = Color(0xFF10B981);
  static const Color accent2 = Color(0xFFF59E0B);
  static const Color accent3 = Color(0xFFEF4444);
  static const Color accent4 = Color(0xFF8B5CF6);

  // Pastel Colors
  static const Color pastelPink = Color(0xFFFDF2F8);
  static const Color pastelBlue = Color(0xFFEFF6FF);
  static const Color pastelGreen = Color(0xFFECFDF5);
  static const Color pastelYellow = Color(0xFFFEFBF0);
  static const Color pastelPurple = Color(0xFFFAF5FF);

  // Neutral Colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // System Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Dark Background Colors
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF252550);

  // Text Colors
  static const Color textPrimary = Color(0xFF171717);
  static const Color textSecondary = Color(0xFF525252);
  static const Color textTertiary = Color(0xFF737373);
  static const Color textOnPrimary = Colors.white;

  // Dark Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFE5E5E5);
  static const Color darkTextTertiary = Color(0xFFA3A3A3);
}

class AppDimensions {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Margin
  static const double marginXS = 4.0;
  static const double marginSM = 8.0;
  static const double marginMD = 16.0;
  static const double marginLG = 24.0;
  static const double marginXL = 32.0;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // Component Sizes
  static const double cardHeight = 120.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 64.0;
}

class AppStrings {
  // App Info
  static const String appName = 'StudyBuddy';
  static const String appTagline = 'Your AI-Powered Study Companion';

  // Authentication
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";

  // Navigation
  static const String home = 'Home';
  static const String study = 'Study';
  static const String quiz = 'Quiz';
  static const String flashcards = 'Flashcards';
  static const String progress = 'Progress';
  static const String profile = 'Profile';

  // Home Dashboard
  static const String welcomeBack = 'Welcome back';
  static const String quickAccess = 'Quick Access';
  static const String trendingStudyPacks = 'Trending Study Packs';
  static const String personalizedForYou = 'Personalized For You';
  static const String dailyChallenges = 'Daily Challenges';
  static const String progressHighlights = 'Progress Highlights';
  static const String featuredTools = 'Featured Tools';
  static const String communityPicks = 'Community Picks';

  // Features
  static const String notesSummarizer = 'Notes Summarizer';
  static const String aiQATutor = 'AI Q&A Tutor';
  static const String quizGenerator = 'Quiz Generator';
  static const String aiFlashcardMaker = 'AI Flashcard Maker';
  static const String smartPlanner = 'Smart Planner';
  static const String voiceTutorMode = 'Voice Tutor Mode';

  // Study Packs
  static const String physicsCrashCourse = 'Physics Crash Course';
  static const String topVocabularyWords = 'Top Vocabulary Words';
  static const String chemistryFormulas = 'Chemistry Formulas';
  static const String interviewQuestions = 'Interview Questions';

  // Progress
  static const String studyStreak = 'Study Streak';
  static const String completedTopics = 'Completed Topics';
  static const String quizAccuracy = 'Quiz Accuracy';
  static const String timeStudied = 'Time Studied';

  // Challenges
  static const String answer5MCQs = 'Answer 5 MCQs';
  static const String reviewFlashcards = 'Review Flashcards';
  static const String completeQuiz = 'Complete Quiz';
  static const String studyForMinutes = 'Study for 30 minutes';

  // Messages
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String error = 'An error occurred';
  static const String success = 'Success';
  static const String tryAgain = 'Try Again';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String create = 'Create';
  static const String update = 'Update';
}

class AppAssets {
  // Icons
  static const String iconsPath = 'assets/icons/';
  static const String imagesPath = 'assets/images/';
  static const String animationsPath = 'assets/animations/';

  // Placeholder URLs for development
  static const String placeholder = 'https://via.placeholder.com/';
  static const String avatarPlaceholder = 'https://via.placeholder.com/150x150/6366F1/FFFFFF?text=';
}
