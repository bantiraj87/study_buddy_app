import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedUpdateService {
  static const String _updateUrl = 'https://api.github.com/repos/bantiraj87/study_buddy_app/releases/latest';
  static const String _lastCheckKey = 'last_update_check';
  static const String _skipVersionKey = 'skip_version';
  static const String _autoCheckEnabledKey = 'auto_check_enabled';
  static const Duration _checkInterval = Duration(hours: 24);
  
  static final Dio _dio = Dio();

  /// Initialize auto-update checking
  static Future<void> initializeAutoUpdates(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final autoCheckEnabled = prefs.getBool(_autoCheckEnabledKey) ?? true;
    
    if (autoCheckEnabled) {
      await _performAutoCheck(context);
    }
  }

  /// Perform automatic update check
  static Future<void> _performAutoCheck(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now - lastCheck > _checkInterval.inMilliseconds) {
      final updateInfo = await checkForUpdate();
      if (updateInfo != null) {
        final skipVersion = prefs.getString(_skipVersionKey);
        if (updateInfo.isForced || skipVersion != updateInfo.latestVersion) {
          if (context.mounted) {
            showAdvancedUpdateDialog(context, updateInfo);
          }
        }
      }
      await prefs.setInt(_lastCheckKey, now);
    }
  }

  /// Check if app update is available
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final response = await _dio.get(_updateUrl);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final latestVersion = data['tag_name']?.replaceAll('v', '') ?? '';
        
        if (data['assets'] == null || data['assets'].isEmpty) {
          debugPrint('No assets found in GitHub release');
          return null;
        }
        
        final downloadUrl = data['assets'][0]['browser_download_url'];
        final updateNotes = data['body'] ?? 'Bug fixes and improvements';
        final fileSize = data['assets'][0]['size'] ?? 0;
        
        if (_isUpdateAvailable(currentVersion, latestVersion)) {
          return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            downloadUrl: downloadUrl,
            updateNotes: updateNotes,
            fileSize: fileSize,
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
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();
      
      while (currentParts.length < 3) currentParts.add(0);
      while (latestParts.length < 3) latestParts.add(0);
      
      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }

  /// Check if this is a forced update
  static bool _isForceUpdate(Map<String, dynamic> data) {
    return data['body']?.toLowerCase().contains('[force]') ?? false;
  }

  /// Request storage permission
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 11+ (API 30+), request MANAGE_EXTERNAL_STORAGE
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 30) {
        // Check if we already have the permission
        if (await Permission.manageExternalStorage.isGranted) {
          return true;
        }
        
        // Request MANAGE_EXTERNAL_STORAGE permission
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else {
        // For older Android versions, use regular storage permission
        if (await Permission.storage.isGranted) {
          return true;
        }
        
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }
  
  /// Get Android SDK version
  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await Permission.storage.request();
        return 30; // Assume API 30+ for modern devices
      } catch (e) {
        return 28; // Fallback to API 28
      }
    }
    return 0;
  }

  /// Show advanced update dialog with download functionality
  static void showAdvancedUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo.isForced,
      builder: (context) => _UpdateDialog(updateInfo: updateInfo),
    );
  }

  /// Download APK file
  static Future<String?> downloadAPK(
    String downloadUrl,
    String fileName,
    Function(int received, int total) onProgress,
  ) async {
    try {
      // Request storage permission
      if (!await _requestStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      // Get download directory
      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      final String savePath = '${directory.path}/$fileName';
      
      // Delete existing file if exists
      final File file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Download file
      await _dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: onProgress,
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
        ),
      );

      return savePath;
    } catch (e) {
      debugPrint('Error downloading APK: $e');
      return null;
    }
  }

  /// Install APK file
  static Future<bool> installAPK(String filePath) async {
    try {
      // Check if APK file exists
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('APK file not found: $filePath');
        return false;
      }
      
      // Request install permission for Android 8+
      if (Platform.isAndroid) {
        final installPermission = await Permission.requestInstallPackages.request();
        if (!installPermission.isGranted) {
          debugPrint('Install permission not granted');
          return false;
        }
      }
      
      // Try to open/install the APK
      final result = await OpenFile.open(filePath, type: 'application/vnd.android.package-archive');
      
      debugPrint('Install result: ${result.type}, message: ${result.message}');
      
      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('Error installing APK: $e');
      return false;
    }
  }

  /// Skip version
  static Future<void> skipVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skipVersionKey, version);
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = (bytes.bitLength - 1) ~/ 10;
    if (i >= suffixes.length) i = suffixes.length - 1;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }
}

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String updateNotes;
  final int fileSize;
  final bool isForced;
  
  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.updateNotes,
    required this.fileSize,
    required this.isForced,
  });
}

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  
  const _UpdateDialog({required this.updateInfo});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';
  bool _downloadCompleted = false;
  String? _downloadedFilePath;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.updateInfo.isForced && !_isDownloading,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              _downloadCompleted ? Icons.download_done : Icons.system_update,
              color: _downloadCompleted ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(_downloadCompleted ? 'Update Downloaded' : 'Update Available'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isDownloading && !_downloadCompleted) ...[
              Text('Current Version: ${widget.updateInfo.currentVersion}'),
              Text('Latest Version: ${widget.updateInfo.latestVersion}'),
              const SizedBox(height: 8),
              Text('Size: ${AdvancedUpdateService.formatFileSize(widget.updateInfo.fileSize)}'),
              const SizedBox(height: 16),
              const Text('What\'s New:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.updateInfo.updateNotes),
            ],
            
            if (_isDownloading) ...[
              Text('Downloading Update...'),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 8),
              Text(_downloadStatus),
            ],
            
            if (_downloadCompleted) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Update downloaded successfully!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              const Text('Tap "Install Now" to install the update.'),
            ],
            
            if (widget.updateInfo.isForced) ...[
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
        actions: _buildActions(),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_isDownloading) {
      return [
        TextButton(
          onPressed: null,
          child: Text('Downloading...'),
        ),
      ];
    }
    
    if (_downloadCompleted) {
      return [
        ElevatedButton.icon(
          onPressed: _installUpdate,
          icon: const Icon(Icons.install_mobile),
          label: const Text('Install Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ];
    }

    return [
      if (!widget.updateInfo.isForced) ...[
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await AdvancedUpdateService.skipVersion(widget.updateInfo.latestVersion);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Skipped version ${widget.updateInfo.latestVersion}'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          child: const Text('Skip Version'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
      ],
      ElevatedButton.icon(
        onPressed: _downloadUpdate,
        icon: const Icon(Icons.download),
        label: const Text('Download Update'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    ];
  }

  Future<void> _downloadUpdate() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus = 'Preparing download...';
    });

    final fileName = 'study_buddy_app_${widget.updateInfo.latestVersion}.apk';
    
    try {
      final filePath = await AdvancedUpdateService.downloadAPK(
        widget.updateInfo.downloadUrl,
        fileName,
        (received, total) {
          setState(() {
            _downloadProgress = received / total;
            _downloadStatus = 
                '${AdvancedUpdateService.formatFileSize(received)} / ${AdvancedUpdateService.formatFileSize(total)}';
          });
        },
      );

      if (filePath != null) {
        setState(() {
          _isDownloading = false;
          _downloadCompleted = true;
          _downloadedFilePath = filePath;
        });
      } else {
        _showError('Download failed. Please try again.');
      }
    } catch (e) {
      _showError('Download failed: $e');
    }
  }

  Future<void> _installUpdate() async {
    if (_downloadedFilePath != null) {
      final success = await AdvancedUpdateService.installAPK(_downloadedFilePath!);
      if (!success) {
        _showError('Installation failed. Please try manually installing the APK.');
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _isDownloading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
