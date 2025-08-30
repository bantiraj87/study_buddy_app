import 'package:flutter/material.dart';
import 'lib/services/advanced_update_service.dart';

void main() {
  runApp(TestUpdateApp());
}

class TestUpdateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Update',
      home: TestUpdateScreen(),
    );
  }
}

class TestUpdateScreen extends StatefulWidget {
  @override
  _TestUpdateScreenState createState() => _TestUpdateScreenState();
}

class _TestUpdateScreenState extends State<TestUpdateScreen> {
  String _status = 'Ready to check for updates';
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔄 Update Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '📱 Update System Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _status,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (_isChecking)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isChecking ? null : _checkForUpdates,
              icon: Icon(Icons.refresh),
              label: Text('Check for Updates'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isChecking ? null : _showUpdateDialog,
              icon: Icon(Icons.system_update),
              label: Text('Show Update Dialog (Test)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isChecking = true;
      _status = 'Checking for updates...';
    });

    try {
      final updateInfo = await AdvancedUpdateService.checkForUpdate();
      
      if (updateInfo != null) {
        setState(() {
          _status = 'Update found! Version ${updateInfo.latestVersion} available.';
          _isChecking = false;
        });
        
        if (mounted) {
          AdvancedUpdateService.showAdvancedUpdateDialog(context, updateInfo);
        }
      } else {
        setState(() {
          _status = 'No updates available. You have the latest version.';
          _isChecking = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error checking for updates: $e';
        _isChecking = false;
      });
    }
  }

  void _showUpdateDialog() {
    // Create a dummy update info for testing
    final testUpdateInfo = UpdateInfo(
      currentVersion: '1.0.3',
      latestVersion: '1.0.4',
      downloadUrl: 'https://github.com/bantiraj87/study_buddy_app/releases/download/v1.0.4/study_buddy_app.apk',
      updateNotes: 'Test update with following improvements:\n\n✅ Fixed in-app update system\n✅ Added automatic APK download\n✅ Improved installation process\n✅ Better permission handling',
      fileSize: 25 * 1024 * 1024, // 25 MB
      isForced: false,
    );

    AdvancedUpdateService.showAdvancedUpdateDialog(context, testUpdateInfo);
  }
}
