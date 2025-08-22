const crypto = require('crypto');

// Function to generate Firebase App Check debug token
function generateDebugToken() {
    // Generate a random debug token (32 bytes)
    const token = crypto.randomBytes(32).toString('hex');
    
    console.log('='.repeat(60));
    console.log('🔥 FIREBASE APP CHECK DEBUG TOKEN 🔥');
    console.log('='.repeat(60));
    console.log();
    console.log('आपका Debug Token:');
    console.log('📋 TOKEN:', token);
    console.log();
    console.log('📱 Android App ID: 1:428716404868:android:746b021d72f6b711ed92d1');
    console.log('🔑 SHA-1: B4:10:7D:7D:F8:89:14:7E:B4:61:39:E2:1E:F4:C2:92:CC:86:C8:B3');
    console.log();
    console.log('💡 इस token को Firebase Console में add करें:');
    console.log('1. https://console.firebase.google.com पर जाएं');
    console.log('2. अपना project select करें: study-buddy-dedde');
    console.log('3. App Check section में जाएं');
    console.log('4. Debug tokens में यह token add करें');
    console.log('5. Token name: Study Buddy Debug Token');
    console.log();
    console.log('🚀 Token को app में use करने के लिए:');
    console.log('export DEBUG_TOKEN="' + token + '"');
    console.log();
    console.log('='.repeat(60));
    
    return token;
}

// Generate the token
const debugToken = generateDebugToken();

// Also save to file
const fs = require('fs');
const tokenData = {
    debug_token: debugToken,
    app_id: '1:428716404868:android:746b021d72f6b711ed92d1',
    sha1: 'B4:10:7D:7D:F8:89:14:7E:B4:61:39:E2:1E:F4:C2:92:CC:86:C8:B3',
    project_id: 'study-buddy-dedde',
    generated_at: new Date().toISOString()
};

fs.writeFileSync('debug_token.json', JSON.stringify(tokenData, null, 2));
console.log('✅ Token को debug_token.json file में save किया गया!');
