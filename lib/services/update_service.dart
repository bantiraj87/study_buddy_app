import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // GitHub API URL for checking latest releases
  static const String _updateUrl = 'https://api.github.com/repos/bantiraj87/study_buddy_app/releases/latest';
  
  /// Check if app update is available
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Check latest version from GitHub releases (or your server)
      final response = await http.get(Uri.parse(_updateUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name'].replaceAll('v', '');
        final downloadUrl = data['assets'][0]['browser_download_url'];
        final updateNotes = data['body'] ?? 'Bug fixes and improvements';
        
        if (_isUpdateAvailable(currentVersion, latestVersion)) {
          return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            downloadUrl: downloadUrl,
            updateNotes: updateNotes,
            isForced: _isForceUpdate(data),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    
    return null;
  }
  
  /// Compare version numbers
  static bool _isUpdateAvailable(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    
    return false;
  }
  
  /// Check if this is a forced update
  static bool _isForceUpdate(Map<String, dynamic> data) {
    return data['body']?.toLowerCase().contains('[force]') ?? false;
  }
  
  /// Show update dialog
  static void showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo.isForced,
      builder: (context) => WillPopScope(
        onWillPop: () async => !updateInfo.isForced,
        child: AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.system_update, color: Colors.green),
              const SizedBox(width: 8),
              const Text('Update Available'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Version: ${updateInfo.currentVersion}'),
              Text('Latest Version: ${updateInfo.latestVersion}'),
              const SizedBox(height: 16),
              const Text('What\'s New:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(updateInfo.updateNotes),
              if (updateInfo.isForced) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is a required update',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!updateInfo.isForced)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Later'),
              ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _downloadUpdate(updateInfo.downloadUrl);
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Download and install update
  static Future<void> _downloadUpdate(String downloadUrl) async {
    try {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error downloading update: $e');
    }
  }
}

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String updateNotes;
  final bool isForced;
  
  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.updateNotes,
    required this.isForced,
  });
}
