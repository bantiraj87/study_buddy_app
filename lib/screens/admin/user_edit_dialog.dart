import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/admin_auth_provider.dart';
import '../../services/admin_database_service.dart';
import '../../models/admin_models.dart';
import '../../models/user_model.dart';

class UserEditDialog extends StatefulWidget {
  final UserModel user;

  const UserEditDialog({
    super.key,
    required this.user,
  });

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog>
    with SingleTickerProviderStateMixin {
  final AdminDatabaseService _adminService = AdminDatabaseService();
  final _formKey = GlobalKey<FormState>();
  
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;

  // Basic Info Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _photoUrlController;

  // Study Data Controllers
  late TextEditingController _studyStreakController;
  late TextEditingController _topicsCompletedController;
  late TextEditingController _quizAccuracyController;

  // Preferences
  Map<String, dynamic> _preferences = {};
  List<String> _interests = [];
  Map<String, dynamic> _studyStatistics = {};

  // Account Status
  bool _isAccountEnabled = true;
  bool _emailVerified = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _photoUrlController.dispose();
    _studyStreakController.dispose();
    _topicsCompletedController.dispose();
    _quizAccuracyController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _photoUrlController = TextEditingController(text: widget.user.photoUrl ?? '');
    
    _studyStreakController = TextEditingController(text: widget.user.studyStreak.toString());
    _topicsCompletedController = TextEditingController(text: widget.user.totalTopicsCompleted.toString());
    _quizAccuracyController = TextEditingController(text: (widget.user.quizAccuracy * 100).toStringAsFixed(1));
    
    _preferences = Map<String, dynamic>.from(widget.user.preferences);
    _interests = List<String>.from(widget.user.interests);
    _studyStatistics = Map<String, dynamic>.from(widget.user.studyStatistics);
    
    // Mock account status - in real app, this would come from Firebase Auth
    _isAccountEnabled = true;
    _emailVerified = true;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AdminAuthProvider>();

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 700,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Edit User: ${widget.user.name}'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (authProvider.hasPermission(Permission.editUsers))
                TextButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Basic Info'),
                Tab(text: 'Study Data'),
                Tab(text: 'Preferences'),
              ],
            ),
          ),
          body: Column(
            children: [
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _errorMessage = null),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBasicInfoTab(),
                      _buildStudyDataTab(),
                      _buildPreferencesTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image Section
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: widget.user.photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                widget.user.photoUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.primary,
                                    ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _photoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Profile Image URL',
                      hintText: 'https://example.com/image.jpg',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final uri = Uri.tryParse(value);
                        if (uri == null || !uri.hasAbsolutePath) {
                          return 'Please enter a valid URL';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),

          // Basic Information Fields
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Account Status Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Account Enabled'),
                    subtitle: const Text('Allow user to login and access the app'),
                    value: _isAccountEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isAccountEnabled = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('Email Verified'),
                    subtitle: const Text('Mark email as verified'),
                    value: _emailVerified,
                    onChanged: (value) {
                      setState(() {
                        _emailVerified = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Account Dates
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow('User ID', widget.user.id),
                  _buildInfoRow('Account Created', _formatDate(widget.user.createdAt)),
                  _buildInfoRow('Last Login', _formatDate(widget.user.lastLoginAt)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Study Statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Study Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _studyStreakController,
                          decoration: const InputDecoration(
                            labelText: 'Study Streak (days)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_fire_department),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final num = int.tryParse(value);
                              if (num == null || num < 0) {
                                return 'Please enter a valid number';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _topicsCompletedController,
                          decoration: const InputDecoration(
                            labelText: 'Topics Completed',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.check_circle),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final num = int.tryParse(value);
                              if (num == null || num < 0) {
                                return 'Please enter a valid number';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _quizAccuracyController,
                      decoration: const InputDecoration(
                        labelText: 'Quiz Accuracy (%)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.analytics),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final num = double.tryParse(value);
                          if (num == null || num < 0 || num > 100) {
                            return 'Please enter a percentage (0-100)';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Study Statistics (Read-only display)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Additional Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _loadUserStatistics,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_studyStatistics.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No additional statistics available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._studyStatistics.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatStatKey(entry.key),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  entry.value.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Interests Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Interests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addInterest,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Interest'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_interests.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No interests selected',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _interests.map((interest) => Chip(
                        label: Text(interest),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _interests.remove(interest);
                          });
                        },
                      )).toList(),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Preferences Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'User Preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addPreference,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Preference'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_preferences.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No preferences set',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._preferences.entries.map((entry) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.grey.shade50,
                          child: ListTile(
                            title: Text(
                              _formatStatKey(entry.key),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(entry.value.toString()),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _preferences.remove(entry.key);
                                });
                              },
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatStatKey(String key) {
    return key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim().split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  // Action Methods
  Future<void> _loadUserStatistics() async {
    try {
      final stats = await _adminService.getUserStatistics(widget.user.id);
      setState(() {
        _studyStatistics = stats;
      });
    } catch (e) {
      _showError('Failed to load statistics: $e');
    }
  }

  Future<void> _addInterest() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Interest'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Interest',
            hintText: 'e.g., Mathematics, Science, History',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && !_interests.contains(result)) {
      setState(() {
        _interests.add(result);
      });
    }
  }

  Future<void> _addPreference() async {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Preference'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Preference Key',
                hintText: 'e.g., theme, language, notifications',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'e.g., dark, english, enabled',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final key = keyController.text.trim();
              final value = valueController.text.trim();
              if (key.isNotEmpty && value.isNotEmpty) {
                Navigator.of(context).pop({'key': key, 'value': value});
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _preferences[result['key']!] = result['value']!;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create updated user model
      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        photoUrl: _photoUrlController.text.trim().isEmpty 
            ? null 
            : _photoUrlController.text.trim(),
        studyStreak: int.tryParse(_studyStreakController.text) ?? widget.user.studyStreak,
        totalTopicsCompleted: int.tryParse(_topicsCompletedController.text) ?? 
            widget.user.totalTopicsCompleted,
        quizAccuracy: (double.tryParse(_quizAccuracyController.text) ?? 
            widget.user.quizAccuracy * 100) / 100,
        interests: _interests,
        preferences: _preferences,
      );

      // Update user in database
      await _adminService.updateUser(updatedUser);

      // Show success message and close dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(updatedUser);
      }
    } catch (e) {
      _showError('Failed to update user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }
}
