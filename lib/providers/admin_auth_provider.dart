import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_models.dart';
import '../services/admin_database_service.dart';

class AdminAuthProvider extends ChangeNotifier {
  final AdminDatabaseService _adminService = AdminDatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AdminUser? _currentAdmin;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  AdminUser? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentAdmin != null;
  bool get isInitialized => _isInitialized;

  // Role-based getters
  bool get isSuperAdmin => _currentAdmin?.role == AdminRole.superAdmin;
  bool get isAdmin => _currentAdmin?.role == AdminRole.admin || isSuperAdmin;
  bool get isModerator => _currentAdmin?.role == AdminRole.moderator || isAdmin;

  // Constructor - Listen to auth state changes
  AdminAuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Check if user is an admin
        await _loadAdminUser(user.uid);
      } else {
        _currentAdmin = null;
        _isInitialized = true;
        notifyListeners();
      }
    });
  }

  Future<void> _loadAdminUser(String userId) async {
    try {
      _setLoading(true);
      final admin = await _adminService.getAdminUser(userId);
      
      if (admin != null && admin.isActive) {
        _currentAdmin = admin;
        _error = null;
        
        // Update last login time
        await _updateLastLogin(admin);
      } else {
        _currentAdmin = null;
        _error = 'Access denied. Admin privileges required.';
      }
      
      _isInitialized = true;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load admin data: $e');
      _currentAdmin = null;
      _isInitialized = true;
      _setLoading(false);
    }
  }

  // Login with email and password
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      // First, check if the email belongs to an admin
      final adminUser = await _adminService.getAdminUserByEmail(email);
      if (adminUser == null) {
        _setError('Access denied. Admin privileges required.');
        _setLoading(false);
        return false;
      }

      if (!adminUser.isActive) {
        _setError('Admin account is deactivated.');
        _setLoading(false);
        return false;
      }

      // Sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _currentAdmin = adminUser;
        await _updateLastLogin(adminUser);
        _setLoading(false);
        return true;
      } else {
        _setError('Login failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Login failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentAdmin = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    }
  }

  // Update last login time
  Future<void> _updateLastLogin(AdminUser admin) async {
    try {
      final updatedAdmin = admin.copyWith(lastLoginAt: DateTime.now());
      await _adminService.updateAdminUser(updatedAdmin);
      _currentAdmin = updatedAdmin;
    } catch (e) {
      // Don't show error for this non-critical operation
      debugPrint('Failed to update last login: $e');
    }
  }

  // Check if current admin has specific permission
  bool hasPermission(Permission permission) {
    return _currentAdmin?.hasPermission(permission) ?? false;
  }

  // Check multiple permissions (user must have ALL permissions)
  bool hasAllPermissions(List<Permission> permissions) {
    if (_currentAdmin == null) return false;
    return permissions.every((permission) => hasPermission(permission));
  }

  // Check multiple permissions (user must have at least ONE permission)
  bool hasAnyPermission(List<Permission> permissions) {
    if (_currentAdmin == null) return false;
    return permissions.any((permission) => hasPermission(permission));
  }

  // Check if current admin can perform action on target admin
  bool canManageAdmin(AdminUser targetAdmin) {
    if (_currentAdmin == null) return false;
    
    // Super admin can manage everyone except other super admins
    if (_currentAdmin!.role == AdminRole.superAdmin) {
      return targetAdmin.role != AdminRole.superAdmin || 
             targetAdmin.id == _currentAdmin!.id; // Can edit own profile
    }
    
    // Admin can manage moderators and content managers
    if (_currentAdmin!.role == AdminRole.admin) {
      return [AdminRole.moderator, AdminRole.contentManager, AdminRole.analyst]
          .contains(targetAdmin.role);
    }
    
    // Others can only edit their own profile
    return targetAdmin.id == _currentAdmin!.id;
  }

  // Sign in with email and password (alias for compatibility)
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final success = await loginWithEmail(email, password);
      if (success) {
        return await _auth.signInWithEmailAndPassword(email: email, password: password);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign out (alias for compatibility)
  Future<void> signOut() async {
    await logout();
  }

  // Create new admin (Super Admin only)
  Future<bool> createAdminUser({
    required String email,
    required String password,
    required String name,
    required AdminRole role,
    String? photoUrl,
    List<Permission> customPermissions = const [],
  }) async {
    if (!hasPermission(Permission.manageAdmins)) {
      _setError('Permission denied: Cannot create admin users');
      return false;
    }

    try {
      _setLoading(true);
      
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create admin user document
        final newAdmin = AdminUser(
          id: credential.user!.uid,
          email: email,
          name: name,
          photoUrl: photoUrl,
          role: role,
          customPermissions: customPermissions,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isActive: true,
          createdBy: _currentAdmin?.id,
        );

        await _adminService.createAdminUser(newAdmin);
        _setLoading(false);
        return true;
      }
      
      _setError('Failed to create admin user');
      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to create admin user: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update admin profile
  Future<bool> updateAdminProfile({
    String? name,
    String? photoUrl,
    AdminRole? role,
    List<Permission>? customPermissions,
    bool? isActive,
  }) async {
    if (_currentAdmin == null) return false;

    try {
      _setLoading(true);
      
      final updatedAdmin = _currentAdmin!.copyWith(
        name: name ?? _currentAdmin!.name,
        photoUrl: photoUrl ?? _currentAdmin!.photoUrl,
        role: role ?? _currentAdmin!.role,
        customPermissions: customPermissions ?? _currentAdmin!.customPermissions,
        isActive: isActive ?? _currentAdmin!.isActive,
      );

      await _adminService.updateAdminUser(updatedAdmin);
      _currentAdmin = updatedAdmin;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to send reset email: $e');
      _setLoading(false);
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _setLoading(true);
      final user = _auth.currentUser;
      
      if (user == null || _currentAdmin == null) {
        _setError('User not authenticated');
        _setLoading(false);
        return false;
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to change password: $e');
      _setLoading(false);
      return false;
    }
  }

  // Get all admin users (for management)
  Future<List<AdminUser>> getAllAdminUsers() async {
    if (!hasPermission(Permission.viewLogs)) {
      throw Exception('Permission denied');
    }
    
    return await _adminService.getAllAdminUsers();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get user-friendly Firebase error messages
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No admin account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This admin account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // Clear all data when provider is disposed
  @override
  void dispose() {
    _currentAdmin = null;
    _isLoading = false;
    _error = null;
    super.dispose();
  }
}
