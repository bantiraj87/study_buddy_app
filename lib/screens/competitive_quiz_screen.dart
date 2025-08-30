import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../data/competitive_exam_data.dart';
import '../screens/competitive_mock_test_screen.dart';
import 'package:intl/intl.dart';

class CompetitiveQuizScreen extends StatefulWidget {
  const CompetitiveQuizScreen({super.key});

  @override
  State<CompetitiveQuizScreen> createState() => _CompetitiveQuizScreenState();
}

class _CompetitiveQuizScreenState extends State<CompetitiveQuizScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CompetitiveExamType? _selectedExamType;
  String _selectedDifficulty = 'All';
  String _selectedLanguage = 'All';
  TestType _selectedTestType = TestType.mockTest;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _difficulties = ['All', 'Easy', 'Moderate', 'Difficult'];
  final List<String> _languages = ['All', 'English', 'Hindi', 'Bilingual'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Competitive Exams'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mock Tests', icon: Icon(Icons.quiz)),
            Tab(text: 'Practice Sets', icon: Icon(Icons.assignment)),
            Tab(text: 'Previous Year', icon: Icon(Icons.history)),
            Tab(text: 'Study Material', icon: Icon(Icons.library_books)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showExamCalendar,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Filter Bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.neutral200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search tests...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppDimensions.radiusMD),
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                _buildExamTypeSelector(),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMockTestsTab(),
                _buildPracticeSetsTab(),
                _buildPreviousYearTab(),
                _buildStudyMaterialTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamTypeSelector() {
    return PopupMenuButton<CompetitiveExamType?>(
      initialValue: _selectedExamType,
      onSelected: (value) {
        setState(() {
          _selectedExamType = value;
        });
      },
      itemBuilder: (context) => [
        const PopupMenuItem<CompetitiveExamType?>(
          value: null,
          child: Text('All Exams'),
        ),
        ...CompetitiveExamType.values.map((type) {
          final category = CompetitiveExamData.examCategories
              .firstWhere((cat) => cat.type == type);
          return PopupMenuItem<CompetitiveExamType>(
            value: type,
            child: Row(
              children: [
                Icon(category.icon, size: 20, color: category.color),
                const SizedBox(width: 8),
                Text(category.shortName),
              ],
            ),
          );
        }),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral300),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedExamType != null
                  ? CompetitiveExamData.examCategories
                      .firstWhere((cat) => cat.type == _selectedExamType!)
                      .icon
                  : Icons.all_inclusive,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              _selectedExamType != null
                  ? CompetitiveExamData.examCategories
                      .firstWhere((cat) => cat.type == _selectedExamType!)
                      .shortName
                  : 'All',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMockTestsTab() {
    final mockTests = CompetitiveExamData.getMockTestSeries(
      examType: _selectedExamType,
    ).where((test) {
      if (_searchController.text.isNotEmpty) {
        return test.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               test.description.toLowerCase().contains(_searchController.text.toLowerCase());
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Featured Mock Tests
        Container(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Text(
                  'Featured Mock Tests',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                  itemCount: mockTests.take(5).length,
                  itemBuilder: (context, index) {
                    final test = mockTests[index];
                    return _buildFeaturedMockTestCard(test);
                  },
                ),
              ),
            ],
          ),
        ),
        
        // All Mock Tests
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Mock Tests',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showTestTypeFilter,
                      icon: const Icon(Icons.tune, size: 18),
                      label: const Text('Filter'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                  itemCount: mockTests.length,
                  itemBuilder: (context, index) {
                    final test = mockTests[index];
                    return _buildMockTestCard(test);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeSetsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Practice Sets',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subject-wise practice sets coming soon!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Practice sets will be available soon!')),
              );
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('Notify me when available'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousYearTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Previous Year Papers',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comprehensive collection of previous year papers\nwith detailed solutions coming soon!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Previous year papers will be available soon!')),
              );
            },
            icon: const Icon(Icons.file_download),
            label: const Text('Download sample papers'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyMaterialTab() {
    final studyMaterials = CompetitiveExamData.getStudyMaterials(
      examType: _selectedExamType,
    );

    if (studyMaterials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Study Materials',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comprehensive study materials and notes\nfor your exam preparation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: studyMaterials.length,
      itemBuilder: (context, index) {
        final material = studyMaterials[index];
        return _buildStudyMaterialCard(material);
      },
    );
  }

  Widget _buildFeaturedMockTestCard(MockTestSeries test) {
    final examCategory = CompetitiveExamData.examCategories
        .firstWhere((cat) => cat.type == test.examType);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            examCategory.color.withOpacity(0.1),
            examCategory.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: examCategory.color.withOpacity(0.2)),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          onTap: () => _startMockTest(test),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      examCategory.icon,
                      color: examCategory.color,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        test.examSubType,
                        style: TextStyle(
                          color: examCategory.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (test.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  test.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  test.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildTestStat(Icons.quiz, '${test.totalQuestions}'),
                    const SizedBox(width: 12),
                    _buildTestStat(Icons.timer, '${test.timeLimit}m'),
                    const SizedBox(width: 12),
                    _buildTestStat(Icons.people, '${test.totalAttempts}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMockTestCard(MockTestSeries test) {
    final examCategory = CompetitiveExamData.examCategories
        .firstWhere((cat) => cat.type == test.examType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          onTap: () => _showMockTestDetails(test),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: examCategory.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: examCategory.color.withOpacity(0.3)),
                  ),
                  child: Icon(
                    examCategory.icon,
                    color: examCategory.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              test.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (test.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent2,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${test.examSubType} • ${test.difficultyLevel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: examCategory.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTestStat(Icons.quiz, '${test.totalQuestions} questions'),
                          const SizedBox(width: 16),
                          _buildTestStat(Icons.timer, '${test.timeLimit} mins'),
                          const SizedBox(width: 16),
                          _buildTestStat(Icons.language, test.language),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textTertiary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudyMaterialCard(StudyMaterial material) {
    final examCategory = CompetitiveExamData.examCategories
        .firstWhere((cat) => cat.type == material.examType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          onTap: () => _downloadStudyMaterial(material),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: examCategory.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  child: Icon(
                    material.type == 'PDF' ? Icons.picture_as_pdf : Icons.video_library,
                    color: examCategory.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${material.subject} • ${material.author}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.accent2,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            material.rating.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.download,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${material.downloads}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${(material.fileSizeBytes / 1024 / 1024).toStringAsFixed(1)} MB',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (material.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _startMockTest(MockTestSeries test) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompetitiveMockTestScreen(
          mockTest: test,
        ),
      ),
    );
  }

  void _showMockTestDetails(MockTestSeries test) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MockTestDetailSheet(test: test),
    );
  }

  void _downloadStudyMaterial(StudyMaterial material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Study Material'),
        content: Text('Download "${material.title}"?\n\nSize: ${(material.fileSizeBytes / 1024 / 1024).toStringAsFixed(1)} MB'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading ${material.title}...')),
              );
              // TODO: Implement actual download functionality
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showExamCalendar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExamCalendarSheet(),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(
        selectedDifficulty: _selectedDifficulty,
        selectedLanguage: _selectedLanguage,
        selectedTestType: _selectedTestType,
        onFiltersChanged: (difficulty, language, testType) {
          setState(() {
            _selectedDifficulty = difficulty;
            _selectedLanguage = language;
            _selectedTestType = testType;
          });
        },
      ),
    );
  }

  void _showTestTypeFilter() {
    // TODO: Implement test type filter
  }
}

// Mock Test Detail Sheet
class _MockTestDetailSheet extends StatelessWidget {
  final MockTestSeries test;

  const _MockTestDetailSheet({required this.test});

  @override
  Widget build(BuildContext context) {
    final examCategory = CompetitiveExamData.examCategories
        .firstWhere((cat) => cat.type == test.examType);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: examCategory.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                              border: Border.all(color: examCategory.color.withOpacity(0.3)),
                            ),
                            child: Icon(
                              examCategory.icon,
                              color: examCategory.color,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  test.title,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  test.examSubType,
                                  style: TextStyle(
                                    color: examCategory.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Description
                      Text(
                        'About This Test',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        test.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Test Details
                      Text(
                        'Test Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildDetailRow('Total Questions', '${test.totalQuestions}'),
                      _buildDetailRow('Total Marks', '${test.totalMarks}'),
                      _buildDetailRow('Time Limit', '${test.timeLimit} minutes'),
                      _buildDetailRow('Difficulty Level', test.difficultyLevel),
                      _buildDetailRow('Language', test.language),
                      _buildDetailRow('Negative Marking', test.hasNegativeMarking ? 'Yes (${test.negativeMarkingRatio})' : 'No'),
                      
                      const SizedBox(height: 24),
                      
                      // Statistics
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard('Total Attempts', '${test.totalAttempts}', Icons.people),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard('Average Score', '${test.averageScore.toInt()}%', Icons.trending_up),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CompetitiveMockTestScreen(
                                  mockTest: test,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Test'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Exam Calendar Sheet
class _ExamCalendarSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final upcomingExams = <ExamSchedule>[];
    
    // Collect all upcoming exams
    for (final category in CompetitiveExamData.examCategories) {
      upcomingExams.addAll(category.upcomingExams);
    }
    
    // Sort by exam date
    upcomingExams.sort((a, b) => a.examDate.compareTo(b.examDate));

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Text(
                  'Upcoming Exams',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
                  itemCount: upcomingExams.length,
                  itemBuilder: (context, index) {
                    final exam = upcomingExams[index];
                    return _buildExamCard(exam);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExamCard(ExamSchedule exam) {
    final daysUntilExam = exam.examDate.difference(DateTime.now()).inDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exam.examName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: daysUntilExam <= 30 ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: daysUntilExam <= 30 ? AppColors.error : AppColors.primary,
                  ),
                ),
                child: Text(
                  daysUntilExam > 0 ? '$daysUntilExam days' : 'Today',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: daysUntilExam <= 30 ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Exam Date: ${DateFormat('dd MMM yyyy').format(exam.examDate)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            'Application End: ${DateFormat('dd MMM yyyy').format(exam.applicationEnd)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Filter Bottom Sheet
class _FilterBottomSheet extends StatefulWidget {
  final String selectedDifficulty;
  final String selectedLanguage;
  final TestType selectedTestType;
  final Function(String, String, TestType) onFiltersChanged;

  const _FilterBottomSheet({
    required this.selectedDifficulty,
    required this.selectedLanguage,
    required this.selectedTestType,
    required this.onFiltersChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _difficulty;
  late String _language;
  late TestType _testType;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.selectedDifficulty;
    _language = widget.selectedLanguage;
    _testType = widget.selectedTestType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Difficulty Filter
          Text(
            'Difficulty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['All', 'Easy', 'Moderate', 'Difficult'].map((difficulty) {
              return ChoiceChip(
                label: Text(difficulty),
                selected: _difficulty == difficulty,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _difficulty = difficulty;
                    });
                  }
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Language Filter
          Text(
            'Language',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['All', 'English', 'Hindi', 'Bilingual'].map((language) {
              return ChoiceChip(
                label: Text(language),
                selected: _language == language,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _language = language;
                    });
                  }
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _difficulty = 'All';
                      _language = 'All';
                      _testType = TestType.mockTest;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFiltersChanged(_difficulty, _language, _testType);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
