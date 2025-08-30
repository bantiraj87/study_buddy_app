import 'package:flutter/material.dart';
import 'lib/services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Testing GitHub API access...');
  
  // Test GitHub API directly
  try {
    final updateInfo = await UpdateService.checkForUpdate();
    
    if (updateInfo != null) {
      print('✅ Update found!');
      print('Current version: ${updateInfo.currentVersion}');
      print('Latest version: ${updateInfo.latestVersion}');
      print('Download URL: ${updateInfo.downloadUrl}');
      print('Update notes: ${updateInfo.updateNotes}');
      print('Is forced: ${updateInfo.isForced}');
    } else {
      print('❌ No updates found or error occurred');
    }
  } catch (e) {
    print('❌ Error testing update service: $e');
  }
  
  print('\nTesting auto-update settings...');
  try {
    final autoUpdateEnabled = await UpdateService.isAutoUpdatesEnabled();
    print('Auto-updates enabled: $autoUpdateEnabled');
  } catch (e) {
    print('Error checking auto-update settings: $e');
  }
}
