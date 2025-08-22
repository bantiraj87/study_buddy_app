# Auto-Update System for Study Buddy App

## Overview

The Study Buddy App now includes a comprehensive auto-update system that automatically checks for new app versions and notifies users when updates are available. This system provides a seamless experience for keeping the app up-to-date with the latest features and security fixes.

## Features

### ✅ Automatic Update Checking
- **Daily Checks**: Automatically checks for updates every 24 hours
- **Smart Timing**: Checks happen in the background without interrupting user experience
- **Configurable**: Users can enable/disable automatic checking

### ✅ User-Friendly Update Dialogs
- **Clear Information**: Shows current version, latest version, and release notes
- **Multiple Options**: Users can update now, skip version, or check later
- **Forced Updates**: Support for critical updates that must be installed

### ✅ Flexible Configuration
- **Toggle Auto-Updates**: Users can enable/disable automatic checking
- **Manual Checks**: Users can manually check for updates at any time
- **Version Skipping**: Users can skip non-critical updates

### ✅ Smart Update Logic
- **Version Comparison**: Intelligent version number comparison
- **Update Caching**: Remembers user preferences and skip decisions
- **Network Aware**: Handles network errors gracefully

## How It Works

### 1. **Initialization**
The auto-update system initializes when the app starts:
```dart
// In main.dart
home: const SimpleAutoUpdater(
  child: AuthWrapper(),
),
```

### 2. **Automatic Checking**
- Runs every 24 hours automatically
- Checks against GitHub releases API
- Compares current version with latest release

### 3. **User Notification**
When an update is found:
- Shows a dialog with update information
- Provides options: Update Now, Skip Version, Later
- For forced updates, only "Update Now" is available

### 4. **Update Process**
- Opens the appropriate store/download link
- On Android: Play Store or direct APK download
- On iOS: App Store
- On Web: Refresh notification

## Implementation Details

### Key Files

1. **`lib/services/update_service.dart`**
   - Core update checking logic
   - GitHub API integration
   - Version comparison algorithms
   - User preference management

2. **`lib/widgets/auto_updater_wrapper.dart`**
   - Wrapper widget for automatic update initialization
   - Integration with upgrader package
   - Simple and full-featured implementations

3. **`lib/widgets/update_settings.dart`**
   - UI for update configuration
   - Toggle automatic updates
   - Manual update checking

4. **`lib/widgets/version_checker.dart`**
   - Manual version checking widget
   - User-friendly update interface

### Dependencies

```yaml
dependencies:
  upgrader: ^11.2.0           # Update checking framework
  package_info_plus: ^8.0.3   # App version information
  shared_preferences: ^2.3.3  # User preferences storage
  http: ^1.2.2                # Network requests
  url_launcher: ^6.3.1        # Open update links
```

## Configuration

### Enable/Disable Auto-Updates

```dart
// Enable automatic updates
await UpdateService.setAutoUpdatesEnabled(true);

// Disable automatic updates
await UpdateService.setAutoUpdatesEnabled(false);

// Check current setting
bool isEnabled = await UpdateService.isAutoUpdatesEnabled();
```

### Manual Update Check

```dart
final updateInfo = await UpdateService.checkForUpdate();
if (updateInfo != null) {
  UpdateService.showUpdateDialog(context, updateInfo);
}
```

### Skip Version

```dart
// Skip a specific version
await UpdateService.skipVersion('1.0.2');
```

## GitHub Release Configuration

### Release Format
Create releases on GitHub with the following format:

```
Tag: v1.0.2
Title: Study Buddy App v1.0.2
Body:
## New Features
- Added dark mode support
- Improved AI responses
- Better error handling

## Bug Fixes
- Fixed crash on startup
- Improved performance

[force] // Add this for forced updates
```

### Assets
Attach the following assets to each release:
- Android: `study_buddy_app-v1.0.2.apk`
- iOS: Link to App Store (in release notes)
- Web: Deployment information

## Usage in Settings Screen

Add update settings to your app's settings screen:

```dart
// In your settings screen
import 'package:study_buddy_app/widgets/update_settings.dart';

// Full settings widget
const UpdateSettings(),

// Or compact version
const CompactUpdateSettings(),
```

## Testing

Use the test file to verify functionality:

```bash
# Run the test app
flutter run test_auto_update.dart
```

The test app includes:
- Manual update checking
- Settings configuration
- Auto-update initialization
- Status monitoring

## User Experience

### First Time
1. User opens app
2. Auto-update initializes (3-second delay)
3. If update available, dialog appears
4. User chooses action

### Daily Usage
1. App checks for updates every 24 hours
2. Only shows dialog if new version available
3. Respects user's "skip version" choices
4. Remembers user preferences

### Settings Access
1. User opens settings
2. Finds "Update Settings" section
3. Can toggle auto-updates on/off
4. Can manually check for updates

## Best Practices

### For Developers

1. **Version Numbering**: Use semantic versioning (e.g., 1.0.2)
2. **Release Notes**: Write clear, user-friendly release notes
3. **Testing**: Test update flow before releasing
4. **Forced Updates**: Use sparingly, only for critical fixes

### For Users

1. **Keep Auto-Updates Enabled**: Ensures security and latest features
2. **Review Release Notes**: Check what's new before updating
3. **Update Promptly**: Don't skip important security updates
4. **Check Manually**: Use manual check if you suspect issues

## Troubleshooting

### Common Issues

1. **No Updates Found**
   - Check GitHub repository URL in `update_service.dart`
   - Verify release format and tags
   - Check network connectivity

2. **Dialog Not Appearing**
   - Verify auto-updates are enabled
   - Check if version was previously skipped
   - Ensure 24-hour interval has passed

3. **Update Download Fails**
   - Check asset links in GitHub release
   - Verify URL launcher permissions
   - Check device storage space

### Debug Mode

Enable debug logging in the upgrader:

```dart
UpgradeAlert(
  upgrader: Upgrader(
    debugLogging: true,
    debugDisplayOnce: false,
    // ... other config
  ),
  child: widget.child,
);
```

## Security Considerations

1. **HTTPS Only**: All update URLs use HTTPS
2. **Signature Verification**: Verify app signatures on install
3. **Official Sources**: Only download from official stores
4. **User Consent**: Always require user approval

## Future Enhancements

- [ ] Automatic background downloads
- [ ] Delta updates for smaller download sizes
- [ ] Multiple update channels (stable, beta)
- [ ] Update scheduling
- [ ] Rollback functionality

## Support

For issues with the auto-update system:

1. Check this documentation
2. Review GitHub issues
3. Test with the provided test app
4. Contact development team

---

**Note**: This auto-update system is designed to work across Android, iOS, and Web platforms. Platform-specific behaviors are handled automatically.
