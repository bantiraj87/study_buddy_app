@echo off
echo Deploying Firestore security rules...
echo.
echo Make sure you have Firebase CLI installed and are logged in.
echo Run: npm install -g firebase-tools
echo Run: firebase login
echo.
pause

echo Deploying rules to Firebase project: study-buddy-dedde
firebase deploy --only firestore:rules --project study-buddy-dedde

echo.
echo Deployment complete!
pause
