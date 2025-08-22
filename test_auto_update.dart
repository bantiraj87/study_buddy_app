import 'package:flutter/material.dart';
import 'package:study_buddy_app/services/update_service.dart';
import 'package:study_buddy_app/widgets/update_settings.dart';
import 'package:study_buddy_app/widgets/version_checker.dart';

/// Simple test app to verify auto-update functionality
class AutoUpdateTestApp extends StatelessWidget {
  const AutoUpdateTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto-Update Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AutoUpdateTestScreen(),
    );
  }
}

class AutoUpdateTestScreen extends StatefulWidget {
  const AutoUpdateTestScreen({super.key});

  @override
  State<AutoUpdateTestScreen> createState() => _AutoUpdateTestScreenState();
}

class _AutoUpdateTestScreenState extends State<AutoUpdateTestScreen> {
  String _status = 'Ready to test auto-update functionality';

  Future<void> _testUpdateCheck() async {
    setState(() {
      _status = 'Checking for updates...';
    });

    try {
      final updateInfo = await UpdateService.checkForUpdate();
      
      if (updateInfo != null) {
        setState(() {
          _status = 'Update found: v${updateInfo.latestVersion}';
        });
        
        if (mounted) {
          UpdateService.showUpdateDialog(context, updateInfo);
        }
      } else {
        setState(() {
          _status = '✅ App is up to date!';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: ${e.toString()}';
      });
    }
  }

  Future<void> _testAutoUpdateSettings() async {
    final isEnabled = await UpdateService.isAutoUpdatesEnabled();
    setState(() {
      _status = 'Auto-updates enabled: $isEnabled';
    });
  }

  Future<void> _initializeAutoUpdates() async {
    setState(() {
      _status = 'Initializing auto-updates...';
    });

    await UpdateService.initializeAutoUpdates(context);
    
    setState(() {
      _status = 'Auto-updates initialized';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto-Update Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.system_update_alt,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Auto-Update System Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _testUpdateCheck,
              icon: const Icon(Icons.search),
              label: const Text('Test Update Check'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _testAutoUpdateSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Check Auto-Update Settings'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _initializeAutoUpdates,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Initialize Auto-Updates'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Update Settings:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const UpdateSettings(),
            const SizedBox(height: 20),
            const Text(
              'Version Checker:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const VersionChecker(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const AutoUpdateTestApp());
}
