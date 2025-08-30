import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../providers/admin_auth_provider.dart';
import '../../services/admin_database_service.dart';
import '../../models/admin_models.dart';
import '../../models/user_model.dart';
import 'user_edit_dialog.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  final AdminDatabaseService _adminService = AdminDatabaseService();
  
  late TabController _tabController;
  UserModel? _user;
  List<ActivityLog> _userActivities = [];
  Map<String, dynamic> _userStatistics = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load user basic info
      final user = await _adminService.getUser(widget.userId);
      
      // Load user activities
      final activities = await _adminService.getUserActivities(widget.userId, limit: 50);
      
      // Load user statistics
      final statistics = await _adminService.getUserStatistics(widget.userId);

      setState(() {
        _user = user;
        _userActivities = activities;
        _userStatistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AdminAuthProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_user?.name ?? 'User Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (authProvider.hasPermission(Permission.editUsers))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editUser,
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              if (authProvider.hasPermission(Permission.banUsers))
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
              if (authProvider.hasPermission(Permission.deleteUsers))
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
          ),
        ],
        bottom: _isLoading || _error != null
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Statistics'),
                  Tab(text: 'Activity'),
                  Tab(text: 'Settings'),
                ],
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _user == null
                  ? _buildUserNotFoundWidget()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(),
                        _buildStatisticsTab(),
                        _buildActivityTab(),
                        _buildSettingsTab(),
                      ],
                    ),
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
            'Error Loading User',
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
            onPressed: _loadUserData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserNotFoundWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'User Not Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'The requested user could not be found.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoCard(),
          const SizedBox(height: 16),
          _buildQuickStatsCard(),
          const SizedBox(height: 16),
          _buildRecentActivityCard(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    final user = _user!;
    final isActive = DateTime.now().difference(user.lastLoginAt).inDays <= 7;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: user.photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                user.photoUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 30,
                              color: AppColors.primary,
                            ),
                    ),
                    if (isActive)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusChip(
                        isActive ? 'Active' : 'Inactive',
                        isActive ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow('User ID', user.id),
            _buildInfoRow('Joined', _formatDate(user.createdAt)),
            _buildInfoRow('Last Login', _formatDate(user.lastLoginAt)),
            _buildInfoRow('Study Streak', '${user.studyStreak} days'),
            _buildInfoRow('Topics Completed', user.totalTopicsCompleted.toString()),
            _buildInfoRow('Quiz Accuracy', '${(user.quizAccuracy * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    final stats = _userStatistics;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Study Time',
                    '${stats['totalStudyHours'] ?? 0}h',
                    Icons.schedule,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Quizzes Taken',
                    '${stats['totalQuizzes'] ?? 0}',
                    Icons.quiz,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Avg. Session',
                    '${stats['avgSessionMinutes'] ?? 0}min',
                    Icons.timer,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Achievements',
                    '${stats['totalAchievements'] ?? 0}',
                    Icons.emoji_events,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    final recentActivities = _userActivities.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _tabController.animateTo(2); // Switch to Activity tab
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentActivities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...recentActivities.map((activity) => _buildActivityItem(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPerformanceChart(),
          const SizedBox(height: 16),
          _buildSubjectBreakdown(),
          const SizedBox(height: 16),
          _buildStudyPatterns(),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    // Placeholder for performance chart
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Performance Chart\n(Chart implementation needed)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectBreakdown() {
    final subjects = _userStatistics['subjectBreakdown'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (subjects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No subject data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...subjects.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(entry.key),
                        ),
                        Expanded(
                          flex: 3,
                          child: LinearProgressIndicator(
                            value: (entry.value['accuracy'] ?? 0.0) / 100.0,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation(
                              _getAccuracyColor((entry.value['accuracy'] ?? 0.0) / 100.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('${entry.value['accuracy']?.toStringAsFixed(1) ?? '0'}%'),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyPatterns() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Study Patterns',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPatternRow('Preferred Study Time', _userStatistics['preferredStudyTime'] ?? 'Not set'),
            _buildPatternRow('Average Session Length', '${_userStatistics['avgSessionMinutes'] ?? 0} minutes'),
            _buildPatternRow('Most Active Day', _userStatistics['mostActiveDay'] ?? 'Not available'),
            _buildPatternRow('Study Consistency', '${_userStatistics['consistencyScore'] ?? 0}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return _userActivities.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Activity Found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'This user has no recorded activity.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _userActivities.length,
            itemBuilder: (context, index) {
              final activity = _userActivities[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: _getActivityIcon(activity.action),
                  title: Text(activity.action),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activity.details.isNotEmpty)
                        Text(activity.details.toString()),
                      Text(
                        _formatDate(activity.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildSettingsTab() {
    final user = _user!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPreferencesCard(),
          const SizedBox(height: 16),
          _buildInterestsCard(),
          const SizedBox(height: 16),
          _buildAccountActionsCard(),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    final preferences = _user!.preferences;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (preferences.isEmpty)
              const Text(
                'No preferences set',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...preferences.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key.replaceAllMapped(
                              RegExp(r'([A-Z])'),
                              (match) => ' ${match.group(1)}',
                            ).trim(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(entry.value.toString()),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsCard() {
    final interests = _user!.interests;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (interests.isEmpty)
              const Text(
                'No interests selected',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests
                    .map((interest) => Chip(
                          label: Text(interest),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActionsCard() {
    final authProvider = context.read<AdminAuthProvider>();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (authProvider.hasPermission(Permission.editUsers))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _editUser,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit User Information'),
                ),
              ),
            if (authProvider.hasPermission(Permission.banUsers))
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _banUser,
                  icon: const Icon(Icons.block, color: Colors.orange),
                  label: const Text('Ban User Account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              ),
            if (authProvider.hasPermission(Permission.deleteUsers))
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deleteUser,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete User Account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
          ].map((widget) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: widget,
              )).toList(),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityLog activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _getActivityIcon(activity.action),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.action,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (activity.details.isNotEmpty)
                  Text(
                    activity.details.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatTimeAgo(activity.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy \'at\' HH:mm').format(date);
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _getActivityIcon(String action) {
    IconData icon;
    Color color;

    switch (action.toLowerCase()) {
      case 'login':
        icon = Icons.login;
        color = Colors.green;
        break;
      case 'logout':
        icon = Icons.logout;
        color = Colors.orange;
        break;
      case 'quiz_completed':
        icon = Icons.quiz;
        color = Colors.blue;
        break;
      case 'study_session':
        icon = Icons.school;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notes;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.orange;
    return Colors.red;
  }

  // Action Methods
  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _loadUserData();
        break;
      case 'ban':
        _banUser();
        break;
      case 'delete':
        _deleteUser();
        break;
    }
  }

  void _editUser() async {
    if (_user == null) return;
    
    final result = await showDialog<UserModel>(
      context: context,
      builder: (context) => UserEditDialog(user: _user!),
    );
    
    if (result != null) {
      // Refresh the user data to show updated information
      setState(() {
        _user = result;
      });
      
      // Optionally reload all user data to get fresh statistics
      _loadUserData();
    }
  }

  void _banUser() {
    // TODO: Implement user banning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User banning feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteUser() {
    // TODO: Implement user deletion with confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User deletion requires confirmation dialog'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
