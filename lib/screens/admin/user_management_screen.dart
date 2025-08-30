import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/admin_auth_provider.dart';
import '../../services/admin_database_service.dart';
import '../../models/admin_models.dart';
import '../../models/user_model.dart';
import 'user_detail_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminDatabaseService _adminService = AdminDatabaseService();
  final TextEditingController _searchController = TextEditingController();
  
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;
  String _sortBy = 'createdAt';
  bool _sortAscending = false;
  
  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  bool? _activeFilter;
  
  // Selection
  Set<String> _selectedUsers = {};
  bool get _hasSelection => _selectedUsers.isNotEmpty;
  bool get _isAllSelected => _selectedUsers.length == _filteredUsers.length && _filteredUsers.isNotEmpty;
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final users = await _adminService.getUsers(
        limit: 100,
        searchQuery: _searchController.text,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
        _selectedUsers.clear();
      });
      
      _sortUsers();
    } catch (e) {
      setState(() {
        _error = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }
  
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = query.isEmpty ||
            user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
        
        final matchesActive = _activeFilter == null ||
            (_activeFilter! ? _isUserActive(user) : !_isUserActive(user));
        
        return matchesSearch && matchesActive;
      }).toList();
    });
    
    _sortUsers();
  }
  
  bool _isUserActive(UserModel user) {
    final daysSinceLastLogin = DateTime.now().difference(user.lastLoginAt).inDays;
    return daysSinceLastLogin <= 7;
  }
  
  void _sortUsers() {
    setState(() {
      _filteredUsers.sort((a, b) {
        int comparison = 0;
        
        switch (_sortBy) {
          case 'name':
            comparison = a.name.compareTo(b.name);
            break;
          case 'email':
            comparison = a.email.compareTo(b.email);
            break;
          case 'createdAt':
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case 'lastLoginAt':
            comparison = a.lastLoginAt.compareTo(b.lastLoginAt);
            break;
          case 'studyStreak':
            comparison = a.studyStreak.compareTo(b.studyStreak);
            break;
        }
        
        return _sortAscending ? comparison : -comparison;
      });
    });
  }
  
  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        _selectedUsers.clear();
      } else {
        _selectedUsers = _filteredUsers.map((user) => user.id).toSet();
      }
    });
  }
  
  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUsers.contains(userId)) {
        _selectedUsers.remove(userId);
      } else {
        _selectedUsers.add(userId);
      }
    });
  }
  
  Future<void> _deleteSelectedUsers() async {
    final authProvider = context.read<AdminAuthProvider>();
    if (!authProvider.hasPermission(Permission.deleteUsers)) {
      _showErrorDialog('Permission denied', 'You do not have permission to delete users.');
      return;
    }
    
    final confirmed = await _showConfirmDialog(
      'Delete Users',
      'Are you sure you want to delete ${_selectedUsers.length} user(s)? This action cannot be undone.',
    );
    
    if (!confirmed) return;
    
    try {
      await _adminService.bulkDeleteUsers(_selectedUsers.toList());
      _showSuccessMessage('Users deleted successfully');
      await _loadUsers();
    } catch (e) {
      _showErrorDialog('Error', 'Failed to delete users: $e');
    }
  }
  
  Future<void> _exportUsers() async {
    final authProvider = context.read<AdminAuthProvider>();
    if (!authProvider.hasPermission(Permission.exportData)) {
      _showErrorDialog('Permission denied', 'You do not have permission to export data.');
      return;
    }
    
    try {
      _showLoadingDialog('Exporting users data...');
      
      final data = await _adminService.exportUsersData(
        startDate: _startDate,
        endDate: _endDate,
      );
      
      Navigator.of(context).pop(); // Close loading dialog
      
      _showSuccessMessage('Export completed. ${data.length} users exported.');
      // TODO: Implement actual file download
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog('Export Error', 'Failed to export users: $e');
    }
  }
  
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildFiltersSheet(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AdminAuthProvider>();
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
          if (authProvider.hasPermission(Permission.exportData))
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportUsers,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
        bottom: _hasSelection
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  color: AppColors.primary.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${_selectedUsers.length} selected',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (authProvider.hasPermission(Permission.deleteUsers))
                        TextButton.icon(
                          onPressed: _deleteSelectedUsers,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildUsersList(),
    );
  }
  
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Users',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUsersList() {
    return Column(
      children: [
        // Search and Sort
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  setState(() {
                    if (_sortBy == value) {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortBy = value;
                      _sortAscending = true;
                    }
                  });
                  _sortUsers();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                  const PopupMenuItem(value: 'email', child: Text('Sort by Email')),
                  const PopupMenuItem(value: 'createdAt', child: Text('Sort by Join Date')),
                  const PopupMenuItem(value: 'lastLoginAt', child: Text('Sort by Last Login')),
                  const PopupMenuItem(value: 'studyStreak', child: Text('Sort by Study Streak')),
                ],
              ),
            ],
          ),
        ),
        
        // Users Count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Text(
                '${_filteredUsers.length} users found',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (_filteredUsers.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _isAllSelected,
                      onChanged: (_) => _toggleSelectAll(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text('Select All'),
                  ],
                ),
            ],
          ),
        ),
        
        // Users List
        Expanded(
          child: _filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or filters',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) => _buildUserCard(_filteredUsers[index]),
                ),
        ),
      ],
    );
  }
  
  Widget _buildUserCard(UserModel user) {
    final isSelected = _selectedUsers.contains(user.id);
    final isActive = _isUserActive(user);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleUserSelection(user.id),
            ),
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: user.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            user.photoUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                ),
                if (isActive)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(
                  isActive ? 'Active' : 'Inactive',
                  isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Streak: ${user.studyStreak} days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            if (context.read<AdminAuthProvider>().hasPermission(Permission.editUsers))
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit User'),
                  ],
                ),
              ),
            if (context.read<AdminAuthProvider>().hasPermission(Permission.deleteUsers))
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
          onSelected: (value) => _handleUserAction(value, user),
        ),
        onTap: () => _viewUserDetails(user),
      ),
    );
  }
  
  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildFiltersSheet() {
    return StatefulBuilder(
      builder: (context, setSheetState) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Active Status Filter
            const Text('User Status:'),
            const SizedBox(height: 8),
            SegmentedButton<bool?>(
              segments: const [
                ButtonSegment(value: null, label: Text('All')),
                ButtonSegment(value: true, label: Text('Active')),
                ButtonSegment(value: false, label: Text('Inactive')),
              ],
              selected: {_activeFilter},
              onSelectionChanged: (selection) {
                setSheetState(() {
                  _activeFilter = selection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Date Range Filter
            const Text('Registration Date:'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setSheetState(() {
                          _startDate = date;
                        });
                      }
                    },
                    child: Text(_startDate != null ? 'From: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : 'Start Date'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setSheetState(() {
                          _endDate = date;
                        });
                      }
                    },
                    child: Text(_endDate != null ? 'To: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : 'End Date'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setSheetState(() {
                        _activeFilter = null;
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Apply filters - already set in setSheetState
                      });
                      Navigator.pop(context);
                      _filterUsers();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleUserAction(String action, UserModel user) async {
    switch (action) {
      case 'view':
        _viewUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }
  
  void _viewUserDetails(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailScreen(userId: user.id),
      ),
    );
  }
  
  void _editUser(UserModel user) {
    // TODO: Implement user editing
    _showErrorDialog('Coming Soon', 'User editing feature will be available soon.');
  }
  
  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await _showConfirmDialog(
      'Delete User',
      'Are you sure you want to delete ${user.name}? This action cannot be undone.',
    );
    
    if (!confirmed) return;
    
    try {
      await _adminService.deleteUser(user.id);
      _showSuccessMessage('User deleted successfully');
      await _loadUsers();
    } catch (e) {
      _showErrorDialog('Error', 'Failed to delete user: $e');
    }
  }
  
  // Helper methods for dialogs
  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
  
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
