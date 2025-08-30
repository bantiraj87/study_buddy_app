import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧹 Clearing update check preferences...');
  
  final prefs = await SharedPreferences.getInstance();
  
  // Clear update-related preferences
  await prefs.remove('last_update_check');
  await prefs.remove('skip_version');
  
  print('✅ Cleared last_update_check');
  print('✅ Cleared skip_version');
  
  // Check current settings
  final autoEnabled = prefs.getBool('auto_check_enabled') ?? true;
  print('🔧 Auto-updates enabled: $autoEnabled');
  
  print('\n📱 Update preferences reset! Next app launch should check for updates immediately.');
}
