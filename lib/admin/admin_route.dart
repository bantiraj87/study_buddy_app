import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import 'admin_web_panel.dart';

/// Route for accessing the admin panel
/// Add this to your main app routing or call it directly
class AdminRoute extends StatelessWidget {
  const AdminRoute({super.key});

  static const String routeName = '/admin';

  /// Method to navigate to admin panel from anywhere in the app
  static void navigateToAdmin(BuildContext context) {
    if (hasAdminAccess(context)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AdminRoute(),
        ),
      );
    } else {
      _showAccessDeniedDialog(context);
    }
  }

  /// Method to check if current user has admin access
  static bool hasAdminAccess([BuildContext? context]) {
    if (context != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Check if user is authenticated
      if (!authProvider.isAuthenticated || userProvider.currentUser == null) {
        return false;
      }
      
      final user = userProvider.currentUser!;
      
      // Check if user has admin privileges and is active
      return user.hasAdminPrivileges && user.isActive && !user.isSuspended;
    }
    
    // Fallback for development - should be false in production
    return true; // Set to false in production
  }
  
  /// Check specific admin permission
  static bool hasPermission(BuildContext context, String permission) {
    if (!hasAdminAccess(context)) return false;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    
    return user?.hasPermission(permission) ?? false;
  }
  
  /// Show access denied dialog
  static void _showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.red),
            SizedBox(width: 8),
            Text('Access Denied'),
          ],
        ),
        content: const Text(
          'You do not have permission to access the admin panel. Please contact an administrator if you believe this is an error.',
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

  @override
  Widget build(BuildContext context) {
    // Check access before building the admin panel
    if (!hasAdminAccess(context)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You do not have permission to access the admin panel.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Please contact an administrator if you believe this is an error.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ChangeNotifierProvider(
      create: (_) => AdminAuthProvider(),
      child: const AdminWebPanel(),
    );
  }
}

/// Widget to add admin access button to your existing screens
class AdminAccessButton extends StatelessWidget {
  final bool showAsFloatingButton;
  
  const AdminAccessButton({
    super.key,
    this.showAsFloatingButton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!AdminRoute.hasAdminAccess()) {
      return const SizedBox.shrink();
    }

    if (showAsFloatingButton) {
      return FloatingActionButton.extended(
        onPressed: () => AdminRoute.navigateToAdmin(context),
        label: const Text('Admin Panel'),
        icon: const Icon(Icons.admin_panel_settings),
        backgroundColor: Colors.red[600],
      );
    }

    return ElevatedButton.icon(
      onPressed: () => AdminRoute.navigateToAdmin(context),
      icon: const Icon(Icons.admin_panel_settings),
      label: const Text('Admin Panel'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
    );
  }
}
