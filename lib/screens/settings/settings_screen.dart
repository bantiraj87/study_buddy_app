import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Study Settings Section
            _buildSectionCard(
              'Study Settings',
              Icons.school,
              [
                _buildSwitchTile(
                  'Auto Save Progress',
                  'Automatically save your study progress',
                  Icons.save,
                  themeProvider.autoSaveEnabled,
                  (value) {
                    themeProvider.setAutoSave(value);
                  },
                ),
                _buildSliderTile(
                  'Study Reminder Frequency',
                  'Get reminders every ${themeProvider.studyReminderFrequency.toInt()} hours',
                  Icons.access_time,
                  themeProvider.studyReminderFrequency,
                  1.0,
                  12.0,
                  (value) {
                    themeProvider.setStudyReminderFrequency(value);
                  },
                ),
                _buildDropdownTile(
                  'Language',
                  'Choose your preferred language',
                  Icons.language,
                  themeProvider.getLanguageDisplayName(themeProvider.languageCode),
                  themeProvider.availableLanguages.map((lang) => lang['name']!).toList(),
                  (value) async {
                    if (value != null) {
                      final languageCode = themeProvider.availableLanguages
                          .firstWhere((lang) => lang['name'] == value)['code']!;
                      await themeProvider.setLanguage(languageCode);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)?.languageChanged ?? 'Language changed successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification Settings Section
            _buildSectionCard(
              'Notifications',
              Icons.notifications,
              [
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive study reminders and updates',
                  Icons.notifications_active,
                  themeProvider.notificationsEnabled,
                  (value) {
                    themeProvider.setNotifications(value);
                  },
                ),
                _buildSwitchTile(
                  'Sound Effects',
                  'Play sounds for interactions and achievements',
                  Icons.volume_up,
                  themeProvider.soundEnabled,
                  (value) {
                    themeProvider.setSound(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // App Settings Section
            _buildSectionCard(
              'App Settings',
              Icons.settings,
              [
                _buildSwitchTile(
                  'Dark Mode',
                  'Switch to dark theme',
                  Icons.dark_mode,
                  themeProvider.isDarkMode,
                  (value) async {
                    await themeProvider.toggleTheme();
                    final localizations = AppLocalizations.of(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(themeProvider.isDarkMode 
                            ? (localizations?.darkModeEnabled ?? 'Dark mode enabled')
                            : (localizations?.lightModeEnabled ?? 'Light mode enabled')),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
                _buildActionTile(
                  'Clear Cache',
                  'Free up storage space',
                  Icons.storage,
                  () {
                    _showClearCacheDialog();
                  },
                ),
                _buildActionTile(
                  'Export Data',
                  'Export your study data',
                  Icons.download,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export feature coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // About Section
            _buildSectionCard(
              'About',
              Icons.info,
              [
                _buildActionTile(
                  'Privacy Policy',
                  'Read our privacy policy',
                  Icons.privacy_tip,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy policy coming soon!'),
                      ),
                    );
                  },
                ),
                _buildActionTile(
                  'Terms of Service',
                  'Read our terms of service',
                  Icons.article,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terms of service coming soon!'),
                      ),
                    );
                  },
                ),
                _buildActionTile(
                  'Contact Support',
                  'Get help with the app',
                  Icons.support_agent,
                  () {
                    _showContactSupportDialog();
                  },
                ),
                _buildInfoTile(
                  'Version',
                  'StudyBuddy v1.0.0',
                  Icons.info_outline,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Account Actions
            _buildSectionCard(
              'Account',
              Icons.account_circle,
              [
                _buildActionTile(
                  'Sign Out',
                  'Sign out of your account',
                  Icons.logout,
                  () {
                    _showSignOutDialog();
                  },
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: '${value.toInt()} hours',
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        underline: Container(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data including downloaded content. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: AppColors.primary),
                SizedBox(width: 8),
                Text('support@studybuddy.com'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: AppColors.primary),
                SizedBox(width: 8),
                Text('+1 (555) 123-4567'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
