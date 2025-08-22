import 'package:flutter/material.dart';
import '../services/update_service.dart';
import '../constants/app_theme.dart';

class UpdateSettings extends StatefulWidget {
  const UpdateSettings({super.key});

  @override
  State<UpdateSettings> createState() => _UpdateSettingsState();
}

class _UpdateSettingsState extends State<UpdateSettings> {
  bool _autoUpdatesEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await UpdateService.isAutoUpdatesEnabled();
    setState(() {
      _autoUpdatesEnabled = enabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleAutoUpdates(bool enabled) async {
    setState(() {
      _autoUpdatesEnabled = enabled;
    });
    
    await UpdateService.setAutoUpdatesEnabled(enabled);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled 
              ? '✅ Automatic updates enabled' 
              : '❌ Automatic updates disabled'
          ),
          backgroundColor: enabled ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _checkForUpdatesManually() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking for updates...'),
          ],
        ),
      ),
    );

    try {
      final updateInfo = await UpdateService.checkForUpdate();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (updateInfo != null) {
          UpdateService.showUpdateDialog(context, updateInfo);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ You have the latest version!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error checking for updates: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.system_update_alt),
          title: Text('Update Settings'),
          trailing: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.system_update_alt, color: Theme.of(context).primaryColor),
            title: const Text('Update Settings'),
            subtitle: const Text('Configure automatic update preferences'),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Automatic Updates'),
            subtitle: const Text('Check for updates daily'),
            value: _autoUpdatesEnabled,
            onChanged: _toggleAutoUpdates,
            secondary: const Icon(Icons.auto_mode),
          ),
          ListTile(
            leading: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            title: const Text('Check for Updates Now'),
            subtitle: const Text('Manually check for the latest version'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _checkForUpdatesManually,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Simplified version for settings screens
class CompactUpdateSettings extends StatefulWidget {
  const CompactUpdateSettings({super.key});

  @override
  State<CompactUpdateSettings> createState() => _CompactUpdateSettingsState();
}

class _CompactUpdateSettingsState extends State<CompactUpdateSettings> {
  bool _autoUpdatesEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await UpdateService.isAutoUpdatesEnabled();
    if (mounted) {
      setState(() {
        _autoUpdatesEnabled = enabled;
      });
    }
  }

  Future<void> _toggleAutoUpdates(bool enabled) async {
    setState(() {
      _autoUpdatesEnabled = enabled;
    });
    await UpdateService.setAutoUpdatesEnabled(enabled);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Automatic Updates'),
      subtitle: const Text('Check for updates automatically'),
      value: _autoUpdatesEnabled,
      onChanged: _toggleAutoUpdates,
      secondary: const Icon(Icons.system_update_alt),
    );
  }
}
