@echo off
echo ========================================
echo  Study Buddy App - Auto Update Setup
echo ========================================
echo.

REM Set colors for better visibility
color 0A

echo Welcome to Auto-Update Setup!
echo.
echo This script will help you configure the auto-update system for your app.
echo.

REM Get GitHub username
set /p GITHUB_USERNAME="Enter your GitHub username: "
if "%GITHUB_USERNAME%"=="" (
    echo ERROR: GitHub username cannot be empty!
    pause
    exit /b 1
)

echo.
echo Configuring auto-update system...
echo GitHub Username: %GITHUB_USERNAME%
echo Repository: %GITHUB_USERNAME%/study_buddy_app
echo.

REM Update the UpdateService file with correct GitHub username
powershell -Command "(Get-Content 'lib\services\update_service.dart') -replace 'YOUR_USERNAME', '%GITHUB_USERNAME%' | Set-Content 'lib\services\update_service.dart'"

echo ✅ UpdateService configured successfully!
echo.

echo ========================================
echo  Next Steps to Complete Setup:
echo ========================================
echo.
echo 1. Create GitHub Repository:
echo    - Go to https://github.com/new
echo    - Repository name: study_buddy_app
echo    - Make it public (for releases)
echo    - Create repository
echo.
echo 2. Push your code to GitHub:
echo    git init
echo    git add .
echo    git commit -m "Initial commit"
echo    git branch -M main
echo    git remote add origin https://github.com/%GITHUB_USERNAME%/study_buddy_app.git
echo    git push -u origin main
echo.
echo 3. Create your first release:
echo    - Build APK: flutter build apk --release
echo    - Go to: https://github.com/%GITHUB_USERNAME%/study_buddy_app/releases/new
echo    - Tag version: v1.0.1
echo    - Release title: Study Buddy App v1.0.1
echo    - Upload APK file from: build/app/outputs/flutter-apk/app-release.apk
echo    - Click "Publish release"
echo.
echo 4. Test auto-update:
echo    - Run your app
echo    - Go to Settings ^> Check for Updates
echo    - Should show "You have the latest version!"
echo.

echo ========================================
echo  How Auto-Update Works:
echo ========================================
echo.
echo ✅ App checks GitHub releases every 24 hours
echo ✅ Users see update dialog when new version available  
echo ✅ Clicking "Update Now" downloads APK from GitHub
echo ✅ Users manually install the new APK
echo ✅ Forced updates possible (add [FORCE] in release notes)
echo.

echo ========================================
echo  For Future Updates:
echo ========================================
echo.
echo 1. Update version in pubspec.yaml (e.g., 1.0.2+3)
echo 2. Build APK: flutter build apk --release
echo 3. Create new GitHub release with new APK
echo 4. Users automatically get update notification!
echo.

echo Setup completed! Your auto-update system is ready.
echo Repository URL: https://github.com/%GITHUB_USERNAME%/study_buddy_app
echo.
pause
