import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_database_service.dart';
import '../../models/admin_models.dart';
import '../../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminDatabaseService _adminService = AdminDatabaseService();
  final TextEditingController _searchController = TextEditingController();
  
  List<UserModel> _users = [];
  List<UserModel> _selectedUsers = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _currentFilter = 'All';
  String _sortBy = 'Created Date';
  bool _sortAscending = false;
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _users.clear();
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
      });
    }

    try {
      final users = await _adminService.getUsers(
        limit: _itemsPerPage,
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      );

      setState(() {
        if (refresh) {
          _users = users;
        } else {
          _users.addAll(users);
        }
        _hasMore = users.length == _itemsPerPage;
        _isLoading = false;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchUsers() {
    setState(() {
      _isSearching = true;
    });
    _loadUsers(refresh: true);
  }

  void _clearSearch() {
    _searchController.clear();
    _loadUsers(refresh: true);
  }

  void _toggleUserSelection(UserModel user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  void _selectAllUsers() {
    setState(() {
      _selectedUsers = List.from(_users);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedUsers.clear();
    });
  }

  Future<void> _deleteSelectedUsers() async {
    if (_selectedUsers.isEmpty) return;

    final confirm = await _showConfirmDialog(
      'Delete Users',
      'Are you sure you want to delete ${_selectedUsers.length} user(s)? This action cannot be undone.',
    );

    if (confirm == true) {
      try {
        final userIds = _selectedUsers.map((u) => u.id).toList();
        await _adminService.bulkDeleteUsers(userIds);
        
        setState(() {
          _users.removeWhere((u) => userIds.contains(u.id));
          _selectedUsers.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully deleted ${userIds.length} user(s)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting users: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(
        user: user,
        onUserUpdated: (updatedUser) {
          setState(() {
            final index = _users.indexWhere((u) => u.id == updatedUser.id);
            if (index != -1) {
              _users[index] = updatedUser;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Management',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'Manage user accounts and permissions',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            // TODO: Implement export functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Export feature coming soon')),
                            );
                          },
                          icon: const Icon(Icons.file_download, size: 18),
                          label: const Text('Export'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _loadUsers,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search and Filters
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or email...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _searchUsers(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _currentFilter,
                      items: ['All', 'Active', 'Inactive']
                          .map((filter) => DropdownMenuItem(
                                value: filter,
                                child: Text(filter),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _currentFilter = value!;
                        });
                        _loadUsers(refresh: true);
                      },
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: ['Created Date', 'Name', 'Email', 'Last Login']
                          .map((sort) => DropdownMenuItem(
                                value: sort,
                                child: Text(sort),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                        // TODO: Implement sorting
                      },
                    ),
                    IconButton(
                      icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                      onPressed: () {
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                        // TODO: Implement sorting
                      },
                    ),
                  ],
                ),

                // Bulk Actions
                if (_selectedUsers.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${_selectedUsers.length} user(s) selected',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _clearSelection,
                          child: const Text('Clear'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _deleteSelectedUsers,
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Delete Selected'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey, width: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _selectedUsers.length == _users.length,
                                  onChanged: (_) {
                                    if (_selectedUsers.length == _users.length) {
                                      _clearSelection();
                                    } else {
                                      _selectAllUsers();
                                    }
                                  },
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'User',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    'Status',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    'Study Streak',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    'Last Login',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 100),
                              ],
                            ),
                          ),

                          // User List
                          Expanded(
                            child: ListView.builder(
                              itemCount: _users.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _users.length) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final user = _users[index];
                                final isSelected = _selectedUsers.contains(user);

                                return Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    leading: Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => _toggleUserSelection(user),
                                    ),
                                    title: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.blue[100],
                                          backgroundImage: user.profileImageUrl != null
                                              ? NetworkImage(user.profileImageUrl!)
                                              : null,
                                          child: user.profileImageUrl == null
                                              ? Text(
                                                  user.name.isNotEmpty
                                                      ? user.name[0].toUpperCase()
                                                      : 'U',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.name.isNotEmpty ? user.name : 'Unknown User',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                user.email,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: user.isActive
                                                  ? Colors.green[100]
                                                  : Colors.red[100],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              user.isActive ? 'Active' : 'Inactive',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: user.isActive
                                                    ? Colors.green[700]
                                                    : Colors.red[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${user.studyStreak} days',
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            _formatDate(user.lastLoginAt),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
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
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'ban',
                                          child: Row(
                                            children: [
                                              Icon(Icons.block, color: Colors.orange),
                                              SizedBox(width: 8),
                                              Text('Ban User'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (action) async {
                                        switch (action) {
                                          case 'view':
                                            _showUserDetails(user);
                                            break;
                                          case 'edit':
                                            // TODO: Implement edit functionality
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Edit feature coming soon'),
                                              ),
                                            );
                                            break;
                                          case 'ban':
                                            // TODO: Implement ban functionality
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Ban feature coming soon'),
                                              ),
                                            );
                                            break;
                                          case 'delete':
                                            final confirm = await _showConfirmDialog(
                                              'Delete User',
                                              'Are you sure you want to delete this user? This action cannot be undone.',
                                            );
                                            if (confirm == true) {
                                              try {
                                                await _adminService.deleteUser(user.id);
                                                setState(() {
                                                  _users.remove(user);
                                                });
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('User deleted successfully'),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Error deleting user: $e'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                            break;
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

class UserDetailsDialog extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onUserUpdated;

  const UserDetailsDialog({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<UserDetailsDialog> createState() => _UserDetailsDialogState();
}

class _UserDetailsDialogState extends State<UserDetailsDialog> {
  final AdminDatabaseService _adminService = AdminDatabaseService();
  Map<String, dynamic> _userStats = {};
  List<ActivityLog> _userActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final stats = await _adminService.getUserStatistics(widget.user.id);
      final activities = await _adminService.getUserActivities(widget.user.id, limit: 10);

      setState(() {
        _userStats = stats;
        _userActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  backgroundImage: widget.user.profileImageUrl != null
                      ? NetworkImage(widget.user.profileImageUrl!)
                      : null,
                  child: widget.user.profileImageUrl == null
                      ? Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name.isNotEmpty ? widget.user.name : 'Unknown User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.user.isActive ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.user.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: widget.user.isActive ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Stats
                        Expanded(
                          flex: 2,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Statistics',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatRow('Total Quizzes', _userStats['totalQuizzes']?.toString() ?? '0'),
                                  _buildStatRow('Study Packs Created', _userStats['totalStudyPacks']?.toString() ?? '0'),
                                  _buildStatRow('Study Hours', _userStats['totalStudyHours']?.toString() ?? '0'),
                                  _buildStatRow('Study Streak', '${widget.user.studyStreak} days'),
                                  _buildStatRow('Quiz Accuracy', '${widget.user.quizAccuracy.toStringAsFixed(1)}%'),
                                  _buildStatRow('Join Date', _formatDate(widget.user.createdAt)),
                                  _buildStatRow('Last Login', _formatDate(widget.user.lastLoginAt)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Recent Activity
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recent Activity',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: _userActivities.isEmpty
                                        ? const Center(child: Text('No recent activity'))
                                        : ListView.separated(
                                            itemCount: _userActivities.length,
                                            separatorBuilder: (context, index) => const Divider(),
                                            itemBuilder: (context, index) {
                                              final activity = _userActivities[index];
                                              return ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                title: Text(
                                                  activity.action.replaceAll('_', ' '),
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                                subtitle: Text(
                                                  _formatActivityTime(activity.timestamp),
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
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
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
