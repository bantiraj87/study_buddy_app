import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
import '../models/admin_models.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/admin_content_screen.dart';
import 'screens/admin_analytics_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'screens/admin_management_screen.dart';
import 'screens/admin_notifications_screen.dart';
import 'screens/admin_logs_screen.dart';

class AdminWebPanel extends StatefulWidget {
  const AdminWebPanel({super.key});

  @override
  State<AdminWebPanel> createState() => _AdminWebPanelState();
}

class _AdminWebPanelState extends State<AdminWebPanel> {
  int _selectedIndex = 0;
  bool _isCollapsed = false;

  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(
      icon: Icons.dashboard,
      title: 'Dashboard',
      screen: const AdminDashboardScreen(),
      requiredPermissions: [Permission.viewAnalytics],
    ),
    AdminMenuItem(
      icon: Icons.people,
      title: 'User Management',
      screen: const AdminUsersScreen(),
      requiredPermissions: [Permission.viewUsers],
    ),
    AdminMenuItem(
      icon: Icons.library_books,
      title: 'Content Management',
      screen: const AdminContentScreen(),
      requiredPermissions: [Permission.viewContent],
    ),
    AdminMenuItem(
      icon: Icons.analytics,
      title: 'Analytics',
      screen: const AdminAnalyticsScreen(),
      requiredPermissions: [Permission.viewAnalytics],
    ),
    AdminMenuItem(
      icon: Icons.notifications,
      title: 'Notifications',
      screen: const AdminNotificationsScreen(),
      requiredPermissions: [Permission.sendNotifications],
    ),
    AdminMenuItem(
      icon: Icons.admin_panel_settings,
      title: 'Admin Management',
      screen: const AdminManagementScreen(),
      requiredPermissions: [Permission.manageAdmins],
    ),
    AdminMenuItem(
      icon: Icons.settings,
      title: 'System Settings',
      screen: const AdminSettingsScreen(),
      requiredPermissions: [Permission.manageSettings],
    ),
    AdminMenuItem(
      icon: Icons.history,
      title: 'Activity Logs',
      screen: const AdminLogsScreen(),
      requiredPermissions: [Permission.viewLogs],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, adminAuth, child) {
        final currentAdmin = adminAuth.currentAdmin;
        if (currentAdmin == null) {
          return const AdminLoginScreen();
        }

        // Filter menu items based on permissions
        final allowedMenuItems = _menuItems.where((item) {
          return item.requiredPermissions.any(
            (permission) => currentAdmin.hasPermission(permission),
          );
        }).toList();

        return Scaffold(
          body: Row(
            children: [
              // Sidebar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isCollapsed ? 70 : 280,
                child: AdminSidebar(
                  isCollapsed: _isCollapsed,
                  selectedIndex: _selectedIndex,
                  menuItems: allowedMenuItems,
                  currentAdmin: currentAdmin,
                  onMenuItemSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  onToggleCollapse: () {
                    setState(() {
                      _isCollapsed = !_isCollapsed;
                    });
                  },
                  onLogout: () => adminAuth.signOut(),
                ),
              ),
              // Main content area
              Expanded(
                child: Column(
                  children: [
                    // Top bar
                    AdminTopBar(
                      currentAdmin: currentAdmin,
                      onMenuPressed: () {
                        setState(() {
                          _isCollapsed = !_isCollapsed;
                        });
                      },
                    ),
                    // Content
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: allowedMenuItems.isNotEmpty
                            ? allowedMenuItems[_selectedIndex].screen
                            : const Center(
                                child: Text(
                                  'You don\'t have permission to access any admin features.',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminMenuItem {
  final IconData icon;
  final String title;
  final Widget screen;
  final List<Permission> requiredPermissions;

  AdminMenuItem({
    required this.icon,
    required this.title,
    required this.screen,
    required this.requiredPermissions,
  });
}

class AdminSidebar extends StatelessWidget {
  final bool isCollapsed;
  final int selectedIndex;
  final List<AdminMenuItem> menuItems;
  final AdminUser currentAdmin;
  final Function(int) onMenuItemSelected;
  final VoidCallback onToggleCollapse;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.isCollapsed,
    required this.selectedIndex,
    required this.menuItems,
    required this.currentAdmin,
    required this.onMenuItemSelected,
    required this.onToggleCollapse,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Panel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Study Buddy App',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Admin info
          if (!isCollapsed)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF3B82F6),
                    backgroundImage: currentAdmin.photoUrl != null
                        ? NetworkImage(currentAdmin.photoUrl!)
                        : null,
                    child: currentAdmin.photoUrl == null
                        ? Text(
                            currentAdmin.name.isNotEmpty
                                ? currentAdmin.name[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentAdmin.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          currentAdmin.role.displayName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const Divider(color: Color(0xFF334155), height: 32),

          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = index == selectedIndex;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onMenuItemSelected(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3B82F6).withOpacity(0.2)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? const Color(0xFF3B82F6)
                                  : Colors.white.withOpacity(0.8),
                              size: 24,
                            ),
                            if (!isCollapsed) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF3B82F6)
                                        : Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Toggle collapse
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onToggleCollapse,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: isCollapsed
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        children: [
                          Icon(
                            isCollapsed
                                ? Icons.keyboard_arrow_right
                                : Icons.keyboard_arrow_left,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Collapse',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Logout
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onLogout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: isCollapsed
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.red.withOpacity(0.8),
                            size: 20,
                          ),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminTopBar extends StatelessWidget {
  final AdminUser currentAdmin;
  final VoidCallback onMenuPressed;

  const AdminTopBar({
    super.key,
    required this.currentAdmin,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
              color: Colors.grey[600],
            ),
            const Spacer(),
            // Quick actions
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {},
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 16),
                // Admin profile
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF3B82F6),
                      backgroundImage: currentAdmin.photoUrl != null
                          ? NetworkImage(currentAdmin.photoUrl!)
                          : null,
                      child: currentAdmin.photoUrl == null
                          ? Text(
                              currentAdmin.name.isNotEmpty
                                  ? currentAdmin.name[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentAdmin.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          currentAdmin.role.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adminAuth = Provider.of<AdminAuthProvider>(context, listen: false);
      await adminAuth.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and title
                    Icon(
                      Icons.admin_panel_settings,
                      size: 64,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Admin Panel Login',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Study Buddy App',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Help text
                    Text(
                      'Contact system administrator for account access',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
