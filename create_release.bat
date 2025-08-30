@echo off
echo Creating GitHub Release for Study Buddy App
echo.

:: Get current version from pubspec.yaml
for /f "tokens=2 delims=: " %%a in ('findstr "version:" pubspec.yaml') do set VERSION=%%a

echo Current version: %VERSION%
echo.

:: Build APK
echo Building APK...
flutter build apk --release
if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo APK built successfully!
echo.

:: Instructions for creating GitHub release
echo Next steps:
echo 1. Go to https://github.com/bantiraj87/study_buddy_app/releases/new
echo 2. Create a new release with tag: v%VERSION%
echo 3. Title: Study Buddy App v%VERSION%
echo 4. Upload the APK from: build\app\outputs\flutter-apk\app-release.apk
echo 5. Add release notes describing new features
echo.

echo Files ready for release:
echo - APK: build\app\outputs\flutter-apk\app-release.apk
echo - Size: 
dir build\app\outputs\flutter-apk\app-release.apk | findstr app-release.apk
echo.

echo Press any key to open GitHub releases page...
pause >nul

:: Open GitHub releases page
start https://github.com/bantiraj87/study_buddy_app/releases/new

echo.
echo Release creation script complete!
pause
