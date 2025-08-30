import 'package:flutter/material.dart';
import 'lib/services/update_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UpdateTestScreen(),
    );
  }
}

class UpdateTestScreen extends StatefulWidget {
  @override
  _UpdateTestScreenState createState() => _UpdateTestScreenState();
}

class _UpdateTestScreenState extends State<UpdateTestScreen> {
  bool _checkingForUpdates = false;
  String _resultMessage = '';

  @override
  void initState() {
    super.initState();
    // Check for updates after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      _checkForUpdatesManually();
    });
  }

  Future<void> _checkForUpdatesManually() async {
    setState(() {
      _checkingForUpdates = true;
      _resultMessage = 'Checking for updates...';
    });

    try {
      final updateInfo = await UpdateService.checkForUpdate();
      
      if (updateInfo != null && mounted) {
        setState(() {
          _resultMessage = 'Update found! Current: ${updateInfo.currentVersion}, Latest: ${updateInfo.latestVersion}';
        });
        
        // Show update dialog
        UpdateService.showUpdateDialog(context, updateInfo);
      } else {
        setState(() {
          _resultMessage = 'No updates available';
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error checking updates: $e';
      });
    }

    setState(() {
      _checkingForUpdates = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_checkingForUpdates)
              CircularProgressIndicator()
            else
              Icon(
                Icons.system_update,
                size: 100,
                color: Colors.blue,
              ),
            SizedBox(height: 20),
            Text(
              'Update Check Test',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                _resultMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkingForUpdates ? null : _checkForUpdatesManually,
              child: Text('Check for Updates'),
            ),
          ],
        ),
      ),
    );
  }
}
