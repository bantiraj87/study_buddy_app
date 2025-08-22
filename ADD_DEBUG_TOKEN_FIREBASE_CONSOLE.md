# 🔥 Add Debug Token to Firebase Console

## 🎯 Your Debug Token Details:
```
Debug Token (UUID v4): bfd61735-a976-4d6c-b28b-b8dc02b6306f
Project ID: study-buddy-dedde
App ID: 1:428716404868:android:746b021d72f6b711ed92d1
SHA-1: B4:10:7D:7D:F8:89:14:7E:B4:61:39:E2:1E:F4:C2:92:CC:86:C8:B3
```

## 📋 Step-by-Step Instructions:

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com
2. Sign in with your Google account
3. Select project: **study-buddy-dedde**

### Step 2: Navigate to App Check
1. In the left sidebar, click **"App Check"**
2. If App Check is not enabled, click **"Get started"**

### Step 3: Configure Android App
1. Look for your Android app with ID: `1:428716404868:android:746b021d72f6b711ed92d1`
2. If not listed, click **"Add app"** and select **Android**
3. Enter package name: `com.example.study_buddy_app`

### Step 4: Add Debug Token
1. Click **"Manage debug tokens"** or **"Add debug token"**
2. In the token field, paste exactly:
   ```
   bfd61735-a976-4d6c-b28b-b8dc02b6306f
   ```
3. Give it a name: **"Study Buddy Debug Token"**
4. Click **"Add"** or **"Save"**

### Step 5: Configure Providers
1. For **Android**, select **"Play Integrity"** as the provider
2. Enable **"Debug"** mode for development
3. Click **"Save"**

### Step 6: Enable Services (IMPORTANT!)
1. Under **"App Check enforcement"**, you'll see services like:
   - Authentication
   - Cloud Firestore
2. For each service, set to **"Unenforced"** for development
3. Or temporarily disable enforcement until testing is complete

## 🚨 CRITICAL: Service Enforcement Settings

**Option A: Disable Enforcement (Recommended for Development)**
- Set Authentication to **"Unenforced"**  
- Set Cloud Firestore to **"Unenforced"**
- This allows your app to work while you test

**Option B: Keep Enforcement (Advanced)**
- Keep services **"Enforced"**
- Ensure debug token is properly added
- More secure but requires correct token setup

## ✅ Verification Steps:

### After Adding Token:
1. Wait 2-3 minutes for changes to propagate
2. Run your Flutter app: `flutter run --device-id=00116648H003406`
3. Try creating an account
4. If successful, you'll see authentication working without token errors

### Expected Success Logs:
```
✅ Firebase Core initialized successfully
✅ Firebase Auth connection successful  
✅ Account creation successful
```

### If Still Getting Errors:
1. **Double-check token**: Ensure `bfd61735-a976-4d6c-b28b-b8dc02b6306f` is correctly added
2. **Set to Unenforced**: Temporarily set all services to "Unenforced" mode
3. **Clear app data**: Uninstall and reinstall the app
4. **Wait**: Sometimes changes take 5-10 minutes to propagate

## 🎯 Quick Alternative (If Token Doesn't Work):

### Temporary Solution:
1. Go to Firebase Console → App Check
2. Click on **"Settings"**
3. **Disable** App Check entirely for development
4. Your app will work immediately

### Re-enable Later:
- Once your app is working, you can re-enable App Check
- Add the debug token when ready for production testing

## 🎉 Expected Result:

After adding the debug token and setting enforcement correctly:
- ✅ No more "Firebase App Check token is invalid" errors
- ✅ User registration/login works perfectly  
- ✅ All AI features accessible
- ✅ Firebase Authentication flows smoothly

## 📞 Need Help?

If you're still seeing token errors after following these steps:
1. Verify the debug token is exactly: `bfd61735-a976-4d6c-b28b-b8dc02b6306f`
2. Set all services to **"Unenforced"** mode temporarily
3. Wait 5-10 minutes after making changes
4. Restart your Flutter app completely

Your app should work perfectly after adding this debug token! 🚀
