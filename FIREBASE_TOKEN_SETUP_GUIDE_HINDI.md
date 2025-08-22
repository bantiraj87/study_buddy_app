# 🔥 Firebase App Check Token Setup Guide

## 🎯 आपका Generated Debug Token:
```
2e1964bbf86d8e7d8f269304a76d42812a721cd06ef54d201671440d6d2467bf
```

## 📱 App Details:
- **Project ID**: study-buddy-dedde  
- **App ID**: 1:428716404868:android:746b021d72f6b711ed92d1
- **SHA-1**: B4:10:7D:7D:F8:89:14:7E:B4:61:39:E2:1E:F4:C2:92:CC:86:C8:B3

## 🔧 Step-by-Step Setup:

### Step 1: Firebase Console खोलें
1. Browser में जाएं: https://console.firebase.google.com
2. Login करें अपने Google account से (bantiraj239@gmail.com)
3. Project select करें: **study-buddy-dedde**

### Step 2: App Check Section में जाएं  
1. Left sidebar में **"App Check"** click करें
2. अगर App Check enable नहीं है तो **"Get Started"** click करें

### Step 3: Debug Token Add करें
1. **"Manage debug tokens"** या **"Add debug token"** click करें
2. Token field में paste करें: 
   ```
   2e1964bbf86d8e7d8f269304a76d42812a721cd06ef54d201671440d6d2467bf
   ```
3. Token name field में लिखें: **"Study Buddy Debug Token"**
4. **"Save"** या **"Add"** click करें

### Step 4: App Check Provider Configure करें
1. Android app के लिए **"Play Integrity"** select करें
2. Debug mode के लिए **"Debug"** provider भी enable करें
3. **"Save"** click करें

### Step 5: Services Enable करें
1. **Firebase Authentication** के लिए enforcement **ENABLE** करें
2. **Cloud Firestore** के लिए enforcement **ENABLE** करें  
3. Settings save करें

## 🚀 App में Token Use करने के लिए:

### Option 1: Environment Variable
```bash
set DEBUG_TOKEN=2e1964bbf86d8e7d8f269304a76d42812a721cd06ef54d201671440d6d2467bf
```

### Option 2: Firebase App Check में Enable करें
App के main.dart file में:

```dart
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Debug mode में token set करें
  if (kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: 'recaptcha-v3-site-key',
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  }
  
  runApp(MyApp());
}
```

## ✅ Verification Steps:

### Step 1: App Run करें
```bash
flutter run
```

### Step 2: Account Create करके Test करें
1. App में account create करें
2. अगर error नहीं आता तो token working है!

### Step 3: Firebase Console में Verify करें  
1. Firebase Console → Authentication → Users
2. नया user दिखना चाहिए

## 🔍 Troubleshooting:

### अगर अभी भी "Token Invalid" error आता है:
1. **App Check को Unenforced mode** में set करें
2. **Debug token** verify करें कि properly add हुआ है
3. **App को restart** करें  
4. **Firebase project settings** check करें

### Alternative Solution (Quick Fix):
1. Firebase Console में जाएं
2. App Check → Settings  
3. **"Unenforced mode"** enable करें सभी services के लिए
4. यह development के लिए safe है

## 📞 अगर समस्या आ रही है:
1. Token: `2e1964bbf86d8e7d8f269304a76d42812a721cd06ef54d201671440d6d2467bf`
2. यह token Firebase Console में manually add करना जरूरी है
3. App Check enforcement को temporarily disable भी कर सकते हैं

## 🎉 Final Result:
Token setup के बाद आपका **AI Study Buddy App** perfect काम करेगा:
- ✅ Account creation 
- ✅ Firebase Authentication
- ✅ All AI features  
- ✅ Notes Summarizer
- ✅ Quiz Generator
- ✅ Flashcards
- ✅ Progress tracking
