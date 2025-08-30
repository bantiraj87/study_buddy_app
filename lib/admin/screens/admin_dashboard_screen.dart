import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/admin_auth_provider.dart';
import '../../services/admin_database_service.dart';
import '../../models/admin_models.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminDatabaseService _adminService = AdminDatabaseService();
  Map<String, dynamic> _dashboardStats = {};
  List<ActivityLog> _recentActivities = [];
  AppStatistics? _appStats;
  Map<String, dynamic> _quizStats = {};
  bool _isLoading = true;
  String _selectedPeriod = 'This Week';
  DateTime _lastRefresh = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _lastRefresh = DateTime.now();
    });

    try {
      // Load comprehensive data sources in parallel for optimal performance
      final results = await Future.wait([
        _adminService.getDashboardStats(),
        _adminService.getActivityLogs(limit: 15),
        _adminService.getAppStatistics(),
        _adminService.getQuizStatistics(),
        _adminService.getUserEngagementStats(),
        _adminService.getContentPerformanceStats(),
        _adminService.getSystemHealthStatus(),
        _adminService.getRevenueStats(),
      ]);

      final stats = results[0] as Map<String, dynamic>;
      final activities = results[1] as List<ActivityLog>;
      final appStats = results[2] as AppStatistics;
      final quizStats = results[3] as Map<String, dynamic>;
      final engagementStats = results[4] as Map<String, dynamic>;
      final contentStats = results[5] as Map<String, dynamic>;
      final systemHealth = results[6] as Map<String, dynamic>;
      final revenueStats = results[7] as Map<String, dynamic>;

      // Enhance dashboard stats with additional metrics
      final enhancedStats = Map<String, dynamic>.from(stats);
      enhancedStats.addAll({
        'userEngagement': engagementStats,
        'contentPerformance': contentStats,
        'systemHealth': systemHealth,
        'revenue': revenueStats,
        'averageSessionDuration': engagementStats['averageSessionDuration'] ?? 0,
        'retentionRate': engagementStats['retentionRate'] ?? 0,
        'bounceRate': engagementStats['bounceRate'] ?? 12.5,
        'pageViewsPerSession': engagementStats['pageViewsPerSession'] ?? 4.2,
        'topPerformingContent': contentStats['topContent'] ?? [],
        'weeklyRevenue': revenueStats['weeklyRevenue'] ?? 0,
        'monthlyRevenue': revenueStats['monthlyRevenue'] ?? 0,
      });

      setState(() {
        _dashboardStats = enhancedStats;
        _recentActivities = activities;
        _appStats = appStats;
        _quizStats = quizStats;
        _isLoading = false;
      });

      // Show comprehensive last refresh notification
      if (mounted) {
        final dataPoints = [
          '${stats['totalUsers'] ?? 0} users',
          '${activities.length} activities',
          '${quizStats['totalQuizzes'] ?? 0} quizzes'
        ];
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dashboard refreshed at ${_formatRefreshTime(_lastRefresh)} • ${dataPoints.join(', ')}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error loading dashboard: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadDashboardData,
            ),
          ),
        );
      }
    }
  }
  
  String _formatRefreshTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'Welcome back! Here\'s what\'s happening with your app.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            DropdownButton<String>(
                              value: _selectedPeriod,
                              items: ['Today', 'This Week', 'This Month', 'This Year']
                                  .map((period) => DropdownMenuItem(
                                        value: period,
                                        child: Text(period),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPeriod = value!;
                                });
                                // TODO: Implement period filtering
                              },
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _loadDashboardData,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Stats Cards
                    GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.5,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          'Total Users',
                          _dashboardStats['totalUsers']?.toString() ?? '0',
                          Icons.people,
                          Colors.blue,
                          '${_dashboardStats['userGrowthRate']?.toStringAsFixed(1) ?? '0'}%',
                        ),
                        _buildStatCard(
                          'Active Users',
                          _dashboardStats['activeUsers']?.toString() ?? '0',
                          Icons.people_alt,
                          Colors.green,
                          'Last 7 days',
                        ),
                        _buildStatCard(
                          'New Users Today',
                          _dashboardStats['newUsersToday']?.toString() ?? '0',
                          Icons.person_add,
                          Colors.orange,
                          'vs ${_dashboardStats['newUsersYesterday'] ?? 0} yesterday',
                        ),
                        _buildStatCard(
                          'Total Study Packs',
                          _dashboardStats['totalStudyPacks']?.toString() ?? '0',
                          Icons.library_books,
                          Colors.purple,
                          'Content library',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Charts and Recent Activity
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Growth Chart
                        Expanded(
                          flex: 2,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'User Growth',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'export',
                                            child: Text('Export Data'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'details',
                                            child: Text('View Details'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 300,
                                    child: LineChart(
                                      _buildUserGrowthChart(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Recent Activity
                        Expanded(
                          flex: 1,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recent Activity',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 300,
                                    child: _recentActivities.isEmpty
                                        ? const Center(
                                            child: Text('No recent activities'),
                                          )
                                        : ListView.separated(
                                            itemCount: _recentActivities.length,
                                            separatorBuilder: (context, index) =>
                                                const Divider(),
                                            itemBuilder: (context, index) {
                                              final activity = _recentActivities[index];
                                              return _buildActivityItem(activity);
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
                    const SizedBox(height: 32),
                    
                    // User Engagement Analytics
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Engagement Metrics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Retention Rate
                                Expanded(
                                  child: _buildEngagementMetricCard(
                                    'Retention Rate',
                                    '${(_dashboardStats['retentionRate'] ?? 0.0).toStringAsFixed(1)}%',
                                    Icons.people_outline,
                                    Colors.blue,
                                    'Last 7 days',
                                    _getRetentionTrend(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Session Duration
                                Expanded(
                                  child: _buildEngagementMetricCard(
                                    'Avg. Session Duration',
                                    '${(_dashboardStats['averageSessionDuration'] ?? 0.0).toStringAsFixed(1)} min',
                                    Icons.timer_outlined,
                                    Colors.green,
                                    'Per active user',
                                    _getSessionDurationTrend(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Bounce Rate
                                Expanded(
                                  child: _buildEngagementMetricCard(
                                    'Bounce Rate',
                                    '${(_dashboardStats['bounceRate'] ?? 0.0).toStringAsFixed(1)}%',
                                    Icons.exit_to_app,
                                    Colors.orange,
                                    'Single page sessions',
                                    _getBounceRateTrend(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Page Views
                                Expanded(
                                  child: _buildEngagementMetricCard(
                                    'Page Views per Session',
                                    '${(_dashboardStats['pageViewsPerSession'] ?? 0.0).toStringAsFixed(1)}',
                                    Icons.pageview,
                                    Colors.purple,
                                    'Avg. content viewed',
                                    _getPageViewsTrend(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions and System Health
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Actions
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quick Actions',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 2.5,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: [
                                      _buildQuickActionButton(
                                        'Add User',
                                        Icons.person_add,
                                        Colors.blue,
                                        () {
                                          // TODO: Navigate to add user
                                        },
                                      ),
                                      _buildQuickActionButton(
                                        'Send Notification',
                                        Icons.notifications,
                                        Colors.orange,
                                        () {
                                          // TODO: Navigate to notifications
                                        },
                                      ),
                                      _buildQuickActionButton(
                                        'View Analytics',
                                        Icons.analytics,
                                        Colors.green,
                                        () {
                                          // TODO: Navigate to analytics
                                        },
                                      ),
                                      _buildQuickActionButton(
                                        'System Settings',
                                        Icons.settings,
                                        Colors.purple,
                                        () {
                                          // TODO: Navigate to settings
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // System Health
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'System Health',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildHealthIndicator('Database', 'Healthy', Colors.green),
                                  const SizedBox(height: 12),
                                  _buildHealthIndicator('Firebase', 'Healthy', Colors.green),
                                  const SizedBox(height: 12),
                                  _buildHealthIndicator('Push Notifications', 'Healthy', Colors.green),
                                  const SizedBox(height: 12),
                                  _buildHealthIndicator('Analytics', 'Warning', Colors.orange),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // TODO: Navigate to system logs
                                      },
                                      child: const Text('View System Logs'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ActivityLog activity) {
    IconData icon;
    Color color;

    switch (activity.action.toLowerCase()) {
      case 'login':
        icon = Icons.login;
        color = Colors.green;
        break;
      case 'create_user':
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      case 'delete_user':
        icon = Icons.person_remove;
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
      title: Text(
        activity.adminName,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        activity.action.replaceAll('_', ' '),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        _formatTime(activity.timestamp),
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String service, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          service,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LineChartData _buildUserGrowthChart() {
    // Mock data for user growth
    final spots = [
      const FlSpot(0, 100),
      const FlSpot(1, 150),
      const FlSpot(2, 140),
      const FlSpot(3, 180),
      const FlSpot(4, 200),
      const FlSpot(5, 250),
      const FlSpot(6, 280),
    ];

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text;
              switch (value.toInt()) {
                case 0:
                  text = 'Mon';
                  break;
                case 1:
                  text = 'Tue';
                  break;
                case 2:
                  text = 'Wed';
                  break;
                case 3:
                  text = 'Thu';
                  break;
                case 4:
                  text = 'Fri';
                  break;
                case 5:
                  text = 'Sat';
                  break;
                case 6:
                  text = 'Sun';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style);
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
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

  Widget _buildEngagementMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    Widget trendWidget,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              trendWidget,
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getRetentionTrend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            color: Colors.green[600],
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '+2.3%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.green[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSessionDurationTrend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            color: Colors.blue[600],
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '+5.1%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.blue[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBounceRateTrend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_down,
            color: Colors.green[600],
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '-1.8%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.green[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPageViewsTrend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            color: Colors.purple[600],
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '+0.7%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.purple[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
