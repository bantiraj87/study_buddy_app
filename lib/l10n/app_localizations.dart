import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('zh'),
    Locale('hi'),
  ];

  // Common strings
  String get appName => 'StudyBuddy';
  String get welcome => _localizedString('welcome');
  String get login => _localizedString('login');
  String get logout => _localizedString('logout');
  String get signup => _localizedString('signup');
  String get email => _localizedString('email');
  String get password => _localizedString('password');
  String get name => _localizedString('name');
  String get profile => _localizedString('profile');
  String get settings => _localizedString('settings');
  String get darkMode => _localizedString('darkMode');
  String get language => _localizedString('language');
  String get notifications => _localizedString('notifications');
  String get soundEffects => _localizedString('soundEffects');
  String get autoSave => _localizedString('autoSave');
  String get studyReminder => _localizedString('studyReminder');
  String get signOut => _localizedString('signOut');
  String get cancel => _localizedString('cancel');
  String get save => _localizedString('save');
  String get edit => _localizedString('edit');
  String get delete => _localizedString('delete');
  String get confirm => _localizedString('confirm');
  String get error => _localizedString('error');
  String get success => _localizedString('success');

  // Study-specific strings
  String get studyStreak => _localizedString('studyStreak');
  String get topicsCompleted => _localizedString('topicsCompleted');
  String get quizAccuracy => _localizedString('quizAccuracy');
  String get totalStudyTime => _localizedString('totalStudyTime');
  String get flashcards => _localizedString('flashcards');
  String get quiz => _localizedString('quiz');
  String get aiTutor => _localizedString('aiTutor');
  String get notesSummarizer => _localizedString('notesSummarizer');

  // Messages
  String get profileUpdateSuccess => _localizedString('profileUpdateSuccess');
  String get profileUpdateError => _localizedString('profileUpdateError');
  String get darkModeEnabled => _localizedString('darkModeEnabled');
  String get lightModeEnabled => _localizedString('lightModeEnabled');
  String get languageChanged => _localizedString('languageChanged');
  String get selectImageSource => _localizedString('selectImageSource');
  String get gallery => _localizedString('gallery');
  String get camera => _localizedString('camera');
  String get profilePhotoUpdated => _localizedString('profilePhotoUpdated');
  String get errorUploadingPhoto => _localizedString('errorUploadingPhoto');
  String get errorPickingImage => _localizedString('errorPickingImage');

  String _localizedString(String key) {
    final Map<String, String> localizedStrings = _getLocalizedStrings();
    return localizedStrings[key] ?? key;
  }

  Map<String, String> _getLocalizedStrings() {
    switch (locale.languageCode) {
      case 'es':
        return _spanishStrings;
      case 'fr':
        return _frenchStrings;
      case 'de':
        return _germanStrings;
      case 'zh':
        return _chineseStrings;
      case 'hi':
        return _hindiStrings;
      default:
        return _englishStrings;
    }
  }

  static const Map<String, String> _englishStrings = {
    'welcome': 'Welcome',
    'login': 'Login',
    'logout': 'Logout',
    'signup': 'Sign Up',
    'email': 'Email',
    'password': 'Password',
    'name': 'Name',
    'profile': 'Profile',
    'settings': 'Settings',
    'darkMode': 'Dark Mode',
    'language': 'Language',
    'notifications': 'Notifications',
    'soundEffects': 'Sound Effects',
    'autoSave': 'Auto Save',
    'studyReminder': 'Study Reminder',
    'signOut': 'Sign Out',
    'cancel': 'Cancel',
    'save': 'Save',
    'edit': 'Edit',
    'delete': 'Delete',
    'confirm': 'Confirm',
    'error': 'Error',
    'success': 'Success',
    'studyStreak': 'Study Streak',
    'topicsCompleted': 'Topics Completed',
    'quizAccuracy': 'Quiz Accuracy',
    'totalStudyTime': 'Total Study Time',
    'flashcards': 'Flashcards',
    'quiz': 'Quiz',
    'aiTutor': 'AI Tutor',
    'notesSummarizer': 'Notes Summarizer',
    'profileUpdateSuccess': 'Profile updated successfully',
    'profileUpdateError': 'Error updating profile',
    'darkModeEnabled': 'Dark mode enabled',
    'lightModeEnabled': 'Light mode enabled',
    'languageChanged': 'Language changed successfully',
    'selectImageSource': 'Select Image Source',
    'gallery': 'Gallery',
    'camera': 'Camera',
    'profilePhotoUpdated': 'Profile photo updated successfully',
    'errorUploadingPhoto': 'Error uploading photo',
    'errorPickingImage': 'Error picking image',
  };

  static const Map<String, String> _spanishStrings = {
    'welcome': 'Bienvenido',
    'login': 'Iniciar Sesión',
    'logout': 'Cerrar Sesión',
    'signup': 'Registrarse',
    'email': 'Correo',
    'password': 'Contraseña',
    'name': 'Nombre',
    'profile': 'Perfil',
    'settings': 'Configuración',
    'darkMode': 'Modo Oscuro',
    'language': 'Idioma',
    'notifications': 'Notificaciones',
    'soundEffects': 'Efectos de Sonido',
    'autoSave': 'Guardado Automático',
    'studyReminder': 'Recordatorio de Estudio',
    'signOut': 'Cerrar Sesión',
    'cancel': 'Cancelar',
    'save': 'Guardar',
    'edit': 'Editar',
    'delete': 'Eliminar',
    'confirm': 'Confirmar',
    'error': 'Error',
    'success': 'Éxito',
    'studyStreak': 'Racha de Estudio',
    'topicsCompleted': 'Temas Completados',
    'quizAccuracy': 'Precisión del Cuestionario',
    'totalStudyTime': 'Tiempo Total de Estudio',
    'flashcards': 'Tarjetas de Estudio',
    'quiz': 'Cuestionario',
    'aiTutor': 'Tutor IA',
    'notesSummarizer': 'Resumidor de Notas',
    'profileUpdateSuccess': 'Perfil actualizado exitosamente',
    'profileUpdateError': 'Error al actualizar perfil',
    'darkModeEnabled': 'Modo oscuro activado',
    'lightModeEnabled': 'Modo claro activado',
    'languageChanged': 'Idioma cambiado exitosamente',
    'selectImageSource': 'Seleccionar Fuente de Imagen',
    'gallery': 'Galería',
    'camera': 'Cámara',
    'profilePhotoUpdated': 'Foto de perfil actualizada exitosamente',
    'errorUploadingPhoto': 'Error al subir foto',
    'errorPickingImage': 'Error al seleccionar imagen',
  };

  static const Map<String, String> _frenchStrings = {
    'welcome': 'Bienvenue',
    'login': 'Connexion',
    'logout': 'Déconnexion',
    'signup': 'S\'inscrire',
    'email': 'Email',
    'password': 'Mot de passe',
    'name': 'Nom',
    'profile': 'Profil',
    'settings': 'Paramètres',
    'darkMode': 'Mode Sombre',
    'language': 'Langue',
    'notifications': 'Notifications',
    'soundEffects': 'Effets Sonores',
    'autoSave': 'Sauvegarde Automatique',
    'studyReminder': 'Rappel d\'Étude',
    'signOut': 'Déconnexion',
    'cancel': 'Annuler',
    'save': 'Sauvegarder',
    'edit': 'Modifier',
    'delete': 'Supprimer',
    'confirm': 'Confirmer',
    'error': 'Erreur',
    'success': 'Succès',
    'studyStreak': 'Série d\'Études',
    'topicsCompleted': 'Sujets Terminés',
    'quizAccuracy': 'Précision du Quiz',
    'totalStudyTime': 'Temps Total d\'Étude',
    'flashcards': 'Cartes Flash',
    'quiz': 'Quiz',
    'aiTutor': 'Tuteur IA',
    'notesSummarizer': 'Résumeur de Notes',
    'profileUpdateSuccess': 'Profil mis à jour avec succès',
    'profileUpdateError': 'Erreur lors de la mise à jour du profil',
    'darkModeEnabled': 'Mode sombre activé',
    'lightModeEnabled': 'Mode clair activé',
    'languageChanged': 'Langue changée avec succès',
    'selectImageSource': 'Sélectionner la Source d\'Image',
    'gallery': 'Galerie',
    'camera': 'Caméra',
    'profilePhotoUpdated': 'Photo de profil mise à jour avec succès',
    'errorUploadingPhoto': 'Erreur lors du téléchargement de la photo',
    'errorPickingImage': 'Erreur lors de la sélection de l\'image',
  };

  static const Map<String, String> _germanStrings = {
    'welcome': 'Willkommen',
    'login': 'Anmelden',
    'logout': 'Abmelden',
    'signup': 'Registrieren',
    'email': 'E-Mail',
    'password': 'Passwort',
    'name': 'Name',
    'profile': 'Profil',
    'settings': 'Einstellungen',
    'darkMode': 'Dunkler Modus',
    'language': 'Sprache',
    'notifications': 'Benachrichtigungen',
    'soundEffects': 'Soundeffekte',
    'autoSave': 'Automatisches Speichern',
    'studyReminder': 'Lernerinnerung',
    'signOut': 'Abmelden',
    'cancel': 'Abbrechen',
    'save': 'Speichern',
    'edit': 'Bearbeiten',
    'delete': 'Löschen',
    'confirm': 'Bestätigen',
    'error': 'Fehler',
    'success': 'Erfolg',
    'studyStreak': 'Lernserie',
    'topicsCompleted': 'Abgeschlossene Themen',
    'quizAccuracy': 'Quiz-Genauigkeit',
    'totalStudyTime': 'Gesamte Lernzeit',
    'flashcards': 'Karteikarten',
    'quiz': 'Quiz',
    'aiTutor': 'KI-Tutor',
    'notesSummarizer': 'Notizen-Zusammenfasser',
    'profileUpdateSuccess': 'Profil erfolgreich aktualisiert',
    'profileUpdateError': 'Fehler beim Aktualisieren des Profils',
    'darkModeEnabled': 'Dunkler Modus aktiviert',
    'lightModeEnabled': 'Heller Modus aktiviert',
    'languageChanged': 'Sprache erfolgreich geändert',
    'selectImageSource': 'Bildquelle Auswählen',
    'gallery': 'Galerie',
    'camera': 'Kamera',
    'profilePhotoUpdated': 'Profilbild erfolgreich aktualisiert',
    'errorUploadingPhoto': 'Fehler beim Hochladen des Fotos',
    'errorPickingImage': 'Fehler beim Auswählen des Bildes',
  };

  static const Map<String, String> _chineseStrings = {
    'welcome': '欢迎',
    'login': '登录',
    'logout': '登出',
    'signup': '注册',
    'email': '邮箱',
    'password': '密码',
    'name': '姓名',
    'profile': '个人资料',
    'settings': '设置',
    'darkMode': '深色模式',
    'language': '语言',
    'notifications': '通知',
    'soundEffects': '音效',
    'autoSave': '自动保存',
    'studyReminder': '学习提醒',
    'signOut': '退出登录',
    'cancel': '取消',
    'save': '保存',
    'edit': '编辑',
    'delete': '删除',
    'confirm': '确认',
    'error': '错误',
    'success': '成功',
    'studyStreak': '学习连续天数',
    'topicsCompleted': '完成的主题',
    'quizAccuracy': '测验准确率',
    'totalStudyTime': '总学习时间',
    'flashcards': '闪卡',
    'quiz': '测验',
    'aiTutor': 'AI导师',
    'notesSummarizer': '笔记总结器',
    'profileUpdateSuccess': '个人资料更新成功',
    'profileUpdateError': '更新个人资料时出错',
    'darkModeEnabled': '已启用深色模式',
    'lightModeEnabled': '已启用浅色模式',
    'languageChanged': '语言更改成功',
    'selectImageSource': '选择图像源',
    'gallery': '图库',
    'camera': '相机',
    'profilePhotoUpdated': '头像更新成功',
    'errorUploadingPhoto': '上传照片时出错',
    'errorPickingImage': '选择图片时出错',
  };

  static const Map<String, String> _hindiStrings = {
    'welcome': 'स्वागत है',
    'login': 'लॉग इन',
    'logout': 'लॉग आउट',
    'signup': 'साइन अप',
    'email': 'ईमेल',
    'password': 'पासवर्ड',
    'name': 'नाम',
    'profile': 'प्रोफ़ाइल',
    'settings': 'सेटिंग्स',
    'darkMode': 'डार्क मोड',
    'language': 'भाषा',
    'notifications': 'अधिसूचनाएं',
    'soundEffects': 'ध्वनि प्रभाव',
    'autoSave': 'ऑटो सेव',
    'studyReminder': 'अध्ययन अनुस्मारक',
    'signOut': 'साइन आउट',
    'cancel': 'रद्द करें',
    'save': 'सेव करें',
    'edit': 'संपादित करें',
    'delete': 'हटाएं',
    'confirm': 'पुष्टि करें',
    'error': 'त्रुटि',
    'success': 'सफलता',
    'studyStreak': 'अध्ययन स्ट्रीक',
    'topicsCompleted': 'पूर्ण विषय',
    'quizAccuracy': 'क्विज़ सटीकता',
    'totalStudyTime': 'कुल अध्ययन समय',
    'flashcards': 'फ्लैशकार्ड',
    'quiz': 'क्विज़',
    'aiTutor': 'एआई ट्यूटर',
    'notesSummarizer': 'नोट्स सारांशकर्ता',
    'profileUpdateSuccess': 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई',
    'profileUpdateError': 'प्रोफ़ाइल अपडेट करने में त्रुटि',
    'darkModeEnabled': 'डार्क मोड सक्षम किया गया',
    'lightModeEnabled': 'लाइट मोड सक्षम किया गया',
    'languageChanged': 'भाषा सफलतापूर्वक बदली गई',
    'selectImageSource': 'छवि स्रोत चुनें',
    'gallery': 'गैलरी',
    'camera': 'कैमरा',
    'profilePhotoUpdated': 'प्रोफ़ाइल फ़ोटो सफलतापूर्वक अपडेट की गई',
    'errorUploadingPhoto': 'फ़ोटो अपलोड करने में त्रुटि',
    'errorPickingImage': 'छवि चुनने में त्रुटि',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((e) => e.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
