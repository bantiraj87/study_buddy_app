# How to Disable Firebase App Check Enforcement

## Problem
Your Firebase project is configured to enforce App Check tokens, which is causing authentication failures with the error:
```
Firebase App Check token is invalid
```

## Solution: Disable App Check Enforcement in Firebase Console

### Step 1: Open Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **study-buddy-dedde**

### Step 2: Navigate to App Check Settings
1. In the left sidebar, click on **App Check**
2. You'll see your Android app listed

### Step 3: Disable Enforcement
1. Click on your Android app in the App Check section
2. Look for **"Enforcement"** settings
3. **Turn OFF** enforcement for:
   - **Firebase Authentication**
   - **Cloud Firestore**
   - **Any other services** that are enabled

### Step 4: Alternative - Unenforced Mode
If you can't find disable options:
1. Look for **"Unenforced"** mode setting
2. Set App Check to **"Unenforced"** mode
3. This allows the app to work without valid tokens

### Step 5: Save Changes
1. Click **Save** or **Apply** to save your changes
2. Changes may take a few minutes to propagate

### Step 6: Test Your App
1. After making changes, try running your app again
2. Account creation should now work without App Check token errors

## Command Line Alternative (if available):
```bash
# If Firebase CLI supports it:
firebase appcheck:settings:set --unenforced=true --project=study-buddy-dedde
```

## Expected Result
After disabling App Check enforcement:
- ✅ Account creation will work normally
- ✅ Firebase Authentication will function without token errors
- ✅ All app features will be accessible

## Notes
- This is safe for development and testing
- For production apps, you'll want to properly configure App Check with valid tokens
- Your app will still be secure with Firebase Auth and Firestore rules
