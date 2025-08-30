import 'package:flutter/material.dart';
import '../admin/admin_route.dart';
import '../screens/auth/auth_wrapper.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/quiz_taking_screen.dart';
import '../screens/competitive_quiz_screen.dart';
import '../screens/competitive_mock_test_screen.dart';
import '../data/competitive_exam_data.dart';

class AppRoutes {
  // Route names
  static const String home = '/';
  static const String auth = '/auth';
  static const String admin = '/admin';
  static const String profile = '/profile';
  static const String quiz = '/quiz';
  static const String competitiveQuiz = '/competitive-quiz';
  static const String mockTest = '/mock-test';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
          settings: settings,
        );
      
      case admin:
        return MaterialPageRoute(
          builder: (_) => const AdminRoute(),
          settings: settings,
        );
      
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      
      case competitiveQuiz:
        return MaterialPageRoute(
          builder: (_) => const CompetitiveQuizScreen(),
          settings: settings,
        );
      
      case mockTest:
        // Extract mockTest from route arguments or provide default
        final mockTestData = settings.arguments as MockTestSeries?;
        return MaterialPageRoute(
          builder: (_) => CompetitiveMockTestScreen(
            mockTest: mockTestData ?? _getDefaultMockTest(),
          ),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Page Not Found'),
            ),
            body: const Center(
              child: Text(
                '404 - Page not found',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          settings: settings,
        );
    }
  }

  // Navigation helpers
  static void navigateToAdmin(BuildContext context) {
    Navigator.pushNamed(context, admin);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  static void navigateToCompetitiveQuiz(BuildContext context) {
    Navigator.pushNamed(context, competitiveQuiz);
  }

  static void navigateToMockTest(BuildContext context) {
    Navigator.pushNamed(context, mockTest);
  }

  // Admin access check
  static bool canAccessAdmin(BuildContext context) {
    return AdminRoute.hasAdminAccess(context);
  }

  // Default mock test for when no specific test is provided
  static MockTestSeries _getDefaultMockTest() {
    return MockTestSeries(
      id: 'default_test',
      title: 'Sample Mock Test',
      description: 'A sample mock test for demonstration',
      examType: CompetitiveExamType.ssc,
      examSubType: 'SSC CGL',
      testType: TestType.fullTest,
      sections: [],
      totalQuestions: 25,
      totalMarks: 50,
      timeLimit: 60,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Moderate',
      createdAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 30)),
      attempts: 0,
      averageScore: 0.0,
      totalAttempts: 0,
      isPremium: false,
      language: 'English',
    );
  }
}

// Admin route guard widget
class AdminGuard extends StatelessWidget {
  final Widget child;
  
  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AppRoutes.canAccessAdmin(context)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You do not have permission to access this area.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return child;
  }
}
