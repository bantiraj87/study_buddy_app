import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import '../services/update_service.dart';

/// Wrapper widget that automatically checks for app updates
class AutoUpdaterWrapper extends StatefulWidget {
  final Widget child;
  
  const AutoUpdaterWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AutoUpdaterWrapper> createState() => _AutoUpdaterWrapperState();
}

class _AutoUpdaterWrapperState extends State<AutoUpdaterWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeAutoUpdates();
  }

  Future<void> _initializeAutoUpdates() async {
    // Wait for the widget to be mounted before checking for updates
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await UpdateService.initializeAutoUpdates(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        debugLogging: true,
        debugDisplayOnce: false,
        durationUntilAlertAgain: const Duration(hours: 24),
      ),
      child: widget.child,
    );
  }
}

/// Simple auto-update checker without Upgrader package UI
class SimpleAutoUpdater extends StatefulWidget {
  final Widget child;
  
  const SimpleAutoUpdater({
    super.key,
    required this.child,
  });

  @override
  State<SimpleAutoUpdater> createState() => _SimpleAutoUpdaterState();
}

class _SimpleAutoUpdaterState extends State<SimpleAutoUpdater> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    // Delay to ensure the app is fully loaded
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      await UpdateService.initializeAutoUpdates(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
