Write-Host "=================================================" -ForegroundColor Green
Write-Host "   STUDY BUDDY APP - AUTOMATIC GITHUB RELEASE" -ForegroundColor Green  
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

# Check if GitHub CLI is installed
try {
    $ghVersion = gh --version 2>$null
    Write-Host "✅ GitHub CLI is ready!" -ForegroundColor Green
} catch {
    Write-Host "❌ GitHub CLI not found!" -ForegroundColor Red
    Write-Host "Please install GitHub CLI first: https://cli.github.com/" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "After installation, run: gh auth login" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if user is authenticated
try {
    gh auth status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ GitHub authentication required!" -ForegroundColor Red
        Write-Host "Please run: gh auth login" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
} catch {
    Write-Host "❌ GitHub authentication failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Get current version from pubspec.yaml
Write-Host "📋 Reading current version..." -ForegroundColor Blue
$pubspecContent = Get-Content "pubspec.yaml" -Raw
$currentVersionMatch = [regex]::Match($pubspecContent, "version:\s*(.+)")
$currentVersion = $currentVersionMatch.Groups[1].Value.Trim()
Write-Host "Current version: $currentVersion" -ForegroundColor Cyan

# Ask for new version
Write-Host ""
$newVersion = Read-Host "🔢 Enter new version (e.g., 1.0.2)"

# Update pubspec.yaml version  
Write-Host ""
Write-Host "📝 Updating pubspec.yaml version to $newVersion..." -ForegroundColor Blue
$newVersionLine = "version: $newVersion+1"
$pubspecContent = $pubspecContent -replace "version:\s*.+", $newVersionLine
Set-Content -Path "pubspec.yaml" -Value $pubspecContent

# Clean and build release APK
Write-Host ""
Write-Host "🧹 Cleaning project..." -ForegroundColor Blue
flutter clean | Out-Null

Write-Host "📦 Getting dependencies..." -ForegroundColor Blue  
flutter pub get | Out-Null

Write-Host "🔨 Building release APK..." -ForegroundColor Blue
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ APK built successfully!" -ForegroundColor Green

# Check if APK exists
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (-Not (Test-Path $apkPath)) {
    Write-Host "❌ APK file not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"  
    exit 1
}

# Rename APK with version
Write-Host "📋 Renaming APK with version..." -ForegroundColor Blue
$versionedApk = "study_buddy_app-v$newVersion.apk"
Copy-Item $apkPath $versionedApk

# Commit version changes
Write-Host ""
Write-Host "📝 Committing version update..." -ForegroundColor Blue
git add pubspec.yaml
git commit -m "🚀 Version bump to v$newVersion" | Out-Null

# Push changes
Write-Host "📤 Pushing changes to GitHub..." -ForegroundColor Blue
git push | Out-Null

# Create release notes
$releaseNotes = @"
## 🎉 Study Buddy App v$newVersion

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

**Note**: This release includes the new auto-update system. Future updates will be even easier!
"@

# Create GitHub Release with APK
Write-Host ""
Write-Host "🎯 Creating GitHub Release..." -ForegroundColor Blue

try {
    gh release create "v$newVersion" $versionedApk --title "Study Buddy App v$newVersion" --notes $releaseNotes --latest
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ SUCCESS! GitHub Release Created Successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎉 Release Details:" -ForegroundColor Green
        Write-Host "   📋 Version: v$newVersion" -ForegroundColor Cyan
        Write-Host "   📱 APK: $versionedApk" -ForegroundColor Cyan  
        Write-Host "   🔗 GitHub: https://github.com/bantiraj87/study_buddy_app/releases/latest" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🔄 Auto-Update System is now ACTIVE!" -ForegroundColor Green
        Write-Host "   - Users will get update notifications automatically" -ForegroundColor White
        Write-Host "   - Next releases will be detected by the app" -ForegroundColor White
        Write-Host "   - One-tap updates from within the app" -ForegroundColor White
        Write-Host ""
        Write-Host "📱 Test the auto-update:" -ForegroundColor Yellow
        Write-Host "   1. Install older version on device" -ForegroundColor White
        Write-Host "   2. Open app and wait 3 seconds" -ForegroundColor White  
        Write-Host "   3. Update dialog should appear" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "❌ Failed to create GitHub release!" -ForegroundColor Red
        Write-Host "Please check your GitHub authentication and try again." -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error creating release: $_" -ForegroundColor Red
}

# Cleanup
Remove-Item $versionedApk -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🏁 Script completed!" -ForegroundColor Green
Read-Host "Press Enter to exit"
