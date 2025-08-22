@echo off
echo ========================================
echo  Firebase Firestore Rules Deployment
echo ========================================
echo.
echo This script will deploy the Firestore rules to fix permission errors.
echo.
echo Prerequisites:
echo - Firebase CLI must be installed
echo - You must be logged into Firebase CLI
echo.
pause

echo.
echo Checking Firebase CLI...
firebase.cmd --version
if %errorlevel% neq 0 (
    echo ERROR: Firebase CLI not found!
    echo Please install it first: npm install -g firebase-tools
    pause
    exit /b 1
)

echo.
echo Logging into Firebase (if needed)...
firebase.cmd login

echo.
echo Deploying Firestore rules...
firebase.cmd deploy --only firestore:rules --project study-buddy-dedde

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   SUCCESS: Firestore rules deployed!
    echo ========================================
    echo.
    echo Your app should now work without permission errors.
    echo Try running your Flutter app again.
) else (
    echo.
    echo ========================================
    echo   ERROR: Failed to deploy rules
    echo ========================================
    echo.
    echo Please check:
    echo 1. You're logged into the correct Firebase account
    echo 2. You have access to the study-buddy-dedde project
    echo 3. Your internet connection is working
)

echo.
pause
