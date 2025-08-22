const crypto = require('crypto');

// Function to generate UUID v4 format debug token
function generateUUIDv4() {
    // Generate 16 random bytes
    const bytes = crypto.randomBytes(16);
    
    // Set version (4) and variant bits according to RFC 4122
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant bits
    
    // Convert to hex and format as UUID
    const hex = bytes.toString('hex');
    const uuid = [
        hex.substring(0, 8),
        hex.substring(8, 12),
        hex.substring(12, 16),
        hex.substring(16, 20),
        hex.substring(20, 32)
    ].join('-');
    
    return uuid;
}

// Generate correct UUID v4 token
const debugToken = generateUUIDv4();

console.log('='.repeat(70));
console.log('🔥 FIREBASE APP CHECK DEBUG TOKEN (UUID v4 FORMAT) 🔥');
console.log('='.repeat(70));
console.log();
console.log('✅ आपका CORRECT Debug Token (UUID v4):');
console.log('📋 TOKEN:', debugToken);
console.log();
console.log('📱 App Details:');
console.log('   Project ID: study-buddy-dedde');
console.log('   Android App ID: 1:428716404868:android:746b021d72f6b711ed92d1');
console.log('   SHA-1: B4:10:7D:7D:F8:89:14:7E:B4:61:39:E2:1E:F4:C2:92:CC:86:C8:B3');
console.log();
console.log('🔧 Firebase Console में इस token को add करें:');
console.log('1. Name field: "STUDY BUDDY" (यह already भरा है)');
console.log('2. Value field में यह token paste करें:', debugToken);
console.log('3. "Save" button click करें');
console.log();
console.log('✅ यह token UUID v4 format में है और काम करेगा!');
console.log('='.repeat(70));

// Save to file with correct format
const fs = require('fs');
const tokenData = {
    debug_token_uuid: debugToken,
    format: "UUID v4",
    app_id: '1:428716404868:android:746b021d72f6b711ed92d1',
    sha1: 'B4:10:7D:7D:F8:89:14:7E:B4:61:39:E2:1E:F4:C2:92:CC:86:C8:B3',
    project_id: 'study-buddy-dedde',
    generated_at: new Date().toISOString()
};

fs.writeFileSync('uuid_debug_token.json', JSON.stringify(tokenData, null, 2));
console.log('💾 UUID Token को uuid_debug_token.json में save किया गया!');
console.log();
console.log('🎯 अब Firebase Console में इस UUID token को use करें:');
console.log('   ' + debugToken);
