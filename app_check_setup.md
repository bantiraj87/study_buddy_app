# Firebase App Check Setup for Study Buddy App

## Current Status
✅ App Check dependency added to pubspec.yaml
✅ App Check initialization added to main.dart
⏳ Debug tokens need to be configured in Firebase Console

## Next Steps for Full Configuration:

### 1. Set up Debug Tokens (For Development)

#### For Android:
1. Run your app in debug mode
2. Check the logs for a debug token (something like: `FirebaseAppCheck: Debug token: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`)
3. Go to Firebase Console > App Check > Apps
4. Select your Android app
5. Click "Manage debug tokens"
6. Add the debug token from your logs

#### For Web:
1. The current setup uses 'debug-token' as placeholder
2. In Firebase Console > App Check > Apps
3. Select your Web app
4. Add 'debug-token' as a debug token
5. For production, you'll need to set up reCAPTCHA v3

#### For iOS:
1. Similar to Android, run in debug mode and check logs
2. Add the debug token in Firebase Console

### 2. Production Configuration

For production apps, replace the debug providers with:

#### Web (reCAPTCHA v3):
- Get reCAPTCHA v3 site key from Google reCAPTCHA console
- Replace 'your-recaptcha-site-key' in main.dart

#### Android (Play Integrity):
- Enable Play Integrity API in Google Cloud Console
- Configure Play Integrity in your app

#### iOS (Device Check):
- Device Check is automatically available on iOS 11+
- No additional setup required

### 3. Testing Commands

Run these to test your app:
```bash
flutter run --debug    # For development with debug tokens
flutter build apk      # Test Android build
flutter build web      # Test web build
```

### 4. Monitoring

- Check Firebase Console > App Check for token usage and metrics
- Monitor your app's requests to ensure they're being verified
- Look for any App Check related errors in your app logs

## Important Notes:

1. **Debug Mode**: The current configuration automatically uses debug tokens when `kDebugMode` is true
2. **Production**: Before releasing, ensure you've configured proper production providers
3. **Security**: Never commit real production tokens to your repository
4. **Testing**: Test authentication and database access after enabling App Check

## Troubleshooting:

If you encounter issues:
1. Check that App Check is properly enforced in Firebase Console
2. Verify debug tokens are correctly added for all platforms
3. Look for App Check related errors in Flutter/Firebase logs
4. Ensure your Firebase project has App Check enabled for the services you're using
