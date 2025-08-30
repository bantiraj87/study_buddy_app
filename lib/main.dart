import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'constants/app_theme.dart';
import 'constants/app_constants.dart';
import 'screens/auth/auth_wrapper.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/study_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/admin_auth_provider.dart';
import 'l10n/app_localizations.dart';
import 'widgets/auto_updater_wrapper.dart';
import 'routes/app_routes.dart';
// import 'test_firebase_connection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    // Use debug provider for development
    // For production, you should use appropriate providers like:
    // - reCAPTCHA provider for web
    // - Device Check for iOS
    // - Play Integrity for Android
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

  print('Firebase App Check enabled - Services are now protected');

  runApp(const StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppStrings.appName,
            theme: AppTheme.lightTheme.copyWith(
              scaffoldBackgroundColor: AppColors.background,
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              scaffoldBackgroundColor: AppColors.darkBackground,
            ),
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            locale: Locale(themeProvider.languageCode),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.generateRoute,
            home: const SimpleAutoUpdater(
              child: AuthWrapper(),
            ),
          );
        },
      ),
    );
  }
}
