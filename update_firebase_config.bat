@echo off
echo Firebase Configuration Update Script
echo =====================================
echo.
echo Step 1: Download new google-services.json from Firebase Console
echo Step 2: Copy the downloaded file to replace the existing one
echo.
echo Current location: android\app\google-services.json
echo.
echo After downloading the new google-services.json file:
echo 1. Copy it to: %CD%\android\app\google-services.json
echo 2. Run: flutter clean
echo 3. Run: flutter pub get
echo 4. Run: flutter run --debug
echo.
pause
echo.
echo Cleaning Flutter project...
flutter clean
echo.
echo Getting dependencies...
flutter pub get
echo.
echo Firebase configuration updated!
echo You can now run: flutter run --debug
pause
