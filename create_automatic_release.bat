@echo off
echo =================================================
echo    STUDY BUDDY APP - AUTOMATIC GITHUB RELEASE
echo =================================================
echo.

REM Check if GitHub CLI is installed
gh --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ GitHub CLI not found!
    echo Please install GitHub CLI first: https://cli.github.com/
    echo.
    echo After installation, run: gh auth login
    pause
    exit /b 1
)

REM Check if user is authenticated
gh auth status >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ GitHub authentication required!
    echo Please run: gh auth login
    pause
    exit /b 1
)

echo ✅ GitHub CLI is ready!
echo.

REM Get current version from pubspec.yaml
echo 📋 Reading current version...
for /f "tokens=2" %%i in ('findstr "version:" pubspec.yaml') do set CURRENT_VERSION=%%i
echo Current version: %CURRENT_VERSION%

REM Ask for new version
echo.
set /p NEW_VERSION=🔢 Enter new version (e.g., 1.0.2): 

REM Update pubspec.yaml version
echo.
echo 📝 Updating pubspec.yaml version to %NEW_VERSION%...
powershell -Command "(Get-Content pubspec.yaml) -replace 'version: %CURRENT_VERSION%', 'version: %NEW_VERSION%+1' | Set-Content pubspec.yaml"

REM Clean and build release APK
echo.
echo 🧹 Cleaning project...
flutter clean >nul 2>&1

echo 📦 Getting dependencies...
flutter pub get >nul 2>&1

echo 🔨 Building release APK...
flutter build apk --release
if %ERRORLEVEL% neq 0 (
    echo ❌ Build failed!
    pause
    exit /b 1
)

echo ✅ APK built successfully!

REM Check if APK exists
if not exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ❌ APK file not found!
    pause
    exit /b 1
)

REM Rename APK with version
echo 📋 Renaming APK with version...
copy "build\app\outputs\flutter-apk\app-release.apk" "study_buddy_app-v%NEW_VERSION%.apk"

REM Commit version changes
echo.
echo 📝 Committing version update...
git add pubspec.yaml
git commit -m "🚀 Version bump to v%NEW_VERSION%" >nul 2>&1

REM Push changes
echo 📤 Pushing changes to GitHub...
git push >nul 2>&1

REM Create GitHub Release with APK
echo.
echo 🎯 Creating GitHub Release...
gh release create v%NEW_VERSION% ^
    "study_buddy_app-v%NEW_VERSION%.apk" ^
    --title "Study Buddy App v%NEW_VERSION%" ^
    --notes "## 🎉 Study Buddy App v%NEW_VERSION%

### ✨ New Features
- 🔄 Auto-Update System - Automatic update checking every 24 hours
- 🔔 Smart Notifications - User-friendly update dialogs  
- ⏭️  Skip Version Feature - Users can skip non-critical updates
- ⚙️  Settings Integration - Toggle auto-updates on/off
- 📱 Cross-Platform Support - Android, iOS, Web ready

### 🔧 Improvements
- ✅ Fixed deprecated WillPopScope issues
- 🚀 Performance optimizations and stability improvements
- 📦 Optimized app size with tree-shaking (52.9MB)
- 🔒 Enhanced security with Firebase App Check
- 🎨 Better UI/UX and error handling

### 🐛 Bug Fixes  
- 🔧 Resolved build compilation issues
- 📝 Fixed code formatting and quality issues
- 🔥 Improved Firebase integration and connectivity
- 🔄 Better state management and provider updates

### 📱 Installation
1. Download the APK file below
2. Enable 'Unknown Sources' in Android settings
3. Install the APK
4. Enjoy the new features!

### 🔄 Auto-Update Feature
From this version onwards, the app will:
- ✅ Automatically check for updates every 24 hours
- 🔔 Notify you when new versions are available  
- ⚡ Allow one-tap updates from GitHub releases
- ⏭️  Let you skip non-critical updates
- ⚙️  Be configurable from app settings

**Note**: This release includes the new auto-update system. Future updates will be even easier!" ^
    --latest

if %ERRORLEVEL% equ 0 (
    echo.
    echo ✅ SUCCESS! GitHub Release Created Successfully!
    echo.
    echo 🎉 Release Details:
    echo    📋 Version: v%NEW_VERSION%
    echo    📱 APK: study_buddy_app-v%NEW_VERSION%.apk
    echo    🔗 GitHub: https://github.com/bantiraj87/study_buddy_app/releases/latest
    echo.
    echo 🔄 Auto-Update System is now ACTIVE!
    echo    - Users will get update notifications automatically
    echo    - Next releases will be detected by the app
    echo    - One-tap updates from within the app
    echo.
    echo 📱 Test the auto-update:
    echo    1. Install older version on device
    echo    2. Open app and wait 3 seconds  
    echo    3. Update dialog should appear
    echo.
) else (
    echo ❌ Failed to create GitHub release!
    echo Please check your GitHub authentication and try again.
)

REM Cleanup
del "study_buddy_app-v%NEW_VERSION%.apk" >nul 2>&1

echo.
echo 🏁 Script completed!
pause
