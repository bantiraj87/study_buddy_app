import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  
  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'en';
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _autoSaveEnabled = true;
  double _studyReminderFrequency = 2.0;

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get autoSaveEnabled => _autoSaveEnabled;
  double get studyReminderFrequency => _studyReminderFrequency;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Constructor - Load saved preferences
  ThemeProvider() {
    _loadPreferences();
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      
      // Load language
      _languageCode = prefs.getString(_languageKey) ?? 'en';
      
      // Load other settings
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _autoSaveEnabled = prefs.getBool('auto_save_enabled') ?? true;
      _studyReminderFrequency = prefs.getDouble('study_reminder_frequency') ?? 2.0;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // Toggle theme mode
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemeMode();
    notifyListeners();
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await _saveThemeMode();
    notifyListeners();
  }

  // Save theme mode to SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    if (_languageCode == languageCode) return;
    
    _languageCode = languageCode;
    await _saveLanguage();
    notifyListeners();
  }

  // Save language to SharedPreferences
  Future<void> _saveLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, _languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  // Update notifications setting
  Future<void> setNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveBoolPreference('notifications_enabled', enabled);
    notifyListeners();
  }

  // Update sound setting
  Future<void> setSound(bool enabled) async {
    _soundEnabled = enabled;
    await _saveBoolPreference('sound_enabled', enabled);
    notifyListeners();
  }

  // Update auto save setting
  Future<void> setAutoSave(bool enabled) async {
    _autoSaveEnabled = enabled;
    await _saveBoolPreference('auto_save_enabled', enabled);
    notifyListeners();
  }

  // Update study reminder frequency
  Future<void> setStudyReminderFrequency(double frequency) async {
    _studyReminderFrequency = frequency;
    await _saveDoublePreference('study_reminder_frequency', frequency);
    notifyListeners();
  }

  // Generic method to save boolean preferences
  Future<void> _saveBoolPreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving $key preference: $e');
    }
  }

  // Generic method to save double preferences
  Future<void> _saveDoublePreference(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(key, value);
    } catch (e) {
      debugPrint('Error saving $key preference: $e');
    }
  }

  // Get language display name
  String getLanguageDisplayName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'zh':
        return '中文';
      case 'hi':
        return 'हिन्दी';
      default:
        return 'English';
    }
  }

  // Get available languages
  List<Map<String, String>> get availableLanguages => [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'hi', 'name': 'हिन्दी'},
  ];
}
