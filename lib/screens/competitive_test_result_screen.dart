import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../data/competitive_exam_data.dart';
import 'package:intl/intl.dart';

class CompetitiveTestResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const CompetitiveTestResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<CompetitiveTestResultScreen> createState() => _CompetitiveTestResultScreenState();
}

class _CompetitiveTestResultScreenState extends State<CompetitiveTestResultScreen>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  late MockTestSeries _mockTest;
  late List<QuestionData> _questions;
  late List<int?> _userAnswers;
  late CompetitiveExamCategory _examCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _mockTest = widget.result['mockTest'] as MockTestSeries;
    _questions = widget.result['questions'] as List<QuestionData>;
    _userAnswers = widget.result['userAnswers'] as List<int?>;
    _examCategory = CompetitiveExamData.examCategories
        .firstWhere((cat) => cat.type == _mockTest.examType);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Test Results'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadReport,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.analytics)),
            Tab(text: 'Analysis', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Solutions', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAnalysisTab(),
          _buildSolutionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        icon: const Icon(Icons.home),
        label: const Text('Back to Home'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final correctAnswers = widget.result['correctAnswers'] as int;
    final incorrectAnswers = widget.result['incorrectAnswers'] as int;
    final unanswered = widget.result['unanswered'] as int;
    final totalQuestions = widget.result['totalQuestions'] as int;
    final totalMarks = widget.result['totalMarks'] as double;
    final accuracy = widget.result['accuracy'] as double;
    final timeSpent = widget.result['timeSpent'] as int;
    final totalTime = widget.result['totalTime'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _examCategory.color,
                  _examCategory.color.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: AppShadows.medium,
            ),
            child: Column(
              children: [
                Icon(
                  _examCategory.icon,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _mockTest.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Test Completed',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(widget.result['completedAt'] as DateTime),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Score Card
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      totalMarks.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '/${_mockTest.totalMarks}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${accuracy.toInt()}% Accuracy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _getAccuracyColor(accuracy),
                  ),
                ),
                const SizedBox(height: 24),
                _buildPerformanceIndicator(accuracy),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Correct',
                  correctAnswers.toString(),
                  AppColors.success,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Incorrect',
                  incorrectAnswers.toString(),
                  AppColors.error,
                  Icons.cancel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Unanswered',
                  unanswered.toString(),
                  AppColors.warning,
                  Icons.help_outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Detailed Stats
          _buildDetailedStatsCard(
            correctAnswers,
            incorrectAnswers,
            unanswered,
            totalQuestions,
            timeSpent,
            totalTime,
          ),

          const SizedBox(height: 24),

          // Performance Analysis
          _buildPerformanceAnalysisCard(accuracy),

          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    final correctAnswers = widget.result['correctAnswers'] as int;
    final incorrectAnswers = widget.result['incorrectAnswers'] as int;
    final unanswered = widget.result['unanswered'] as int;
    
    // Subject-wise analysis
    Map<String, Map<String, int>> subjectAnalysis = {};
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = _userAnswers[i];
      
      if (!subjectAnalysis.containsKey(question.topic)) {
        subjectAnalysis[question.topic] = {
          'correct': 0,
          'incorrect': 0,
          'unanswered': 0,
          'total': 0,
        };
      }
      
      subjectAnalysis[question.topic]!['total'] = subjectAnalysis[question.topic]!['total']! + 1;
      
      if (userAnswer == null) {
        subjectAnalysis[question.topic]!['unanswered'] = subjectAnalysis[question.topic]!['unanswered']! + 1;
      } else if (userAnswer == question.correctAnswer) {
        subjectAnalysis[question.topic]!['correct'] = subjectAnalysis[question.topic]!['correct']! + 1;
      } else {
        subjectAnalysis[question.topic]!['incorrect'] = subjectAnalysis[question.topic]!['incorrect']! + 1;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Performance Chart
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Performance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPerformancePieChart(correctAnswers, incorrectAnswers, unanswered),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Subject-wise Analysis
          Text(
            'Topic-wise Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...subjectAnalysis.entries.map((entry) {
            return _buildSubjectAnalysisCard(
              entry.key,
              entry.value['correct']!,
              entry.value['incorrect']!,
              entry.value['unanswered']!,
              entry.value['total']!,
            );
          }),

          const SizedBox(height: 24),

          // Time Analysis
          _buildTimeAnalysisCard(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSolutionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        final userAnswer = _userAnswers[index];
        final isCorrect = userAnswer == question.correctAnswer;
        final isUnanswered = userAnswer == null;

        return _buildSolutionCard(question, userAnswer, index + 1, isCorrect, isUnanswered);
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsCard(
    int correctAnswers,
    int incorrectAnswers,
    int unanswered,
    int totalQuestions,
    int timeSpent,
    int totalTime,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Questions Attempted', '${totalQuestions - unanswered}/$totalQuestions'),
          _buildDetailRow('Correct Answers', '$correctAnswers'),
          _buildDetailRow('Incorrect Answers', '$incorrectAnswers'),
          _buildDetailRow('Unanswered Questions', '$unanswered'),
          const Divider(height: 24),
          _buildDetailRow('Time Spent', _formatDuration(timeSpent)),
          _buildDetailRow('Time Remaining', _formatDuration(totalTime - timeSpent)),
          _buildDetailRow('Average Time per Question', _formatDuration((timeSpent / (totalQuestions - unanswered)).round())),
          
          if (_mockTest.hasNegativeMarking) ...[
            const Divider(height: 24),
            _buildDetailRow('Marks Lost (Negative)', '${(incorrectAnswers * _mockTest.negativeMarkingRatio).toStringAsFixed(1)}'),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceAnalysisCard(double accuracy) {
    String performanceLevel;
    Color performanceColor;
    String recommendation;
    
    if (accuracy >= 80) {
      performanceLevel = 'Excellent';
      performanceColor = AppColors.success;
      recommendation = 'Outstanding performance! You\'re well prepared for this exam.';
    } else if (accuracy >= 60) {
      performanceLevel = 'Good';
      performanceColor = AppColors.accent2;
      recommendation = 'Good work! Focus on weak areas to improve further.';
    } else if (accuracy >= 40) {
      performanceLevel = 'Average';
      performanceColor = AppColors.warning;
      recommendation = 'You need more practice. Review concepts and take more tests.';
    } else {
      performanceLevel = 'Needs Improvement';
      performanceColor = AppColors.error;
      recommendation = 'Focus on understanding basic concepts before attempting more tests.';
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: performanceColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Analysis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Text(
                'Performance Level: ',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                performanceLevel,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: performanceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: BoxDecoration(
              color: performanceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: performanceColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: performanceColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      color: performanceColor,
                      fontWeight: FontWeight.w500,
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

  Widget _buildPerformanceIndicator(double accuracy) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: accuracy / 100,
                strokeWidth: 8,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(_getAccuracyColor(accuracy)),
              ),
            ),
            Column(
              children: [
                Text(
                  '${accuracy.toInt()}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'Score',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformancePieChart(int correct, int incorrect, int unanswered) {
    final total = correct + incorrect + unanswered;
    
    return Column(
      children: [
        Container(
          height: 200,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 20,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neutral200),
                  ),
                ),
                // This would be replaced with a proper pie chart in a real app
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Questions',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('Correct', correct, AppColors.success),
            _buildLegendItem('Incorrect', incorrect, AppColors.error),
            _buildLegendItem('Unanswered', unanswered, AppColors.warning),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectAnalysisCard(String subject, int correct, int incorrect, int unanswered, int total) {
    final accuracy = total > 0 ? (correct / total) * 100 : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${accuracy.toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getAccuracyColor(accuracy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: accuracy / 100,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(_getAccuracyColor(accuracy)),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$correct Correct', style: const TextStyle(fontSize: 12, color: AppColors.success)),
              Text('$incorrect Incorrect', style: const TextStyle(fontSize: 12, color: AppColors.error)),
              Text('$unanswered Unanswered', style: const TextStyle(fontSize: 12, color: AppColors.warning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysisCard() {
    final timeSpent = widget.result['timeSpent'] as int;
    final totalTime = widget.result['totalTime'] as int;
    final totalQuestions = widget.result['totalQuestions'] as int;
    final timePercentage = (timeSpent / totalTime) * 100;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time Utilization', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: timePercentage / 100,
                      backgroundColor: AppColors.neutral200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        timePercentage > 90 ? AppColors.error :
                        timePercentage > 75 ? AppColors.warning :
                        AppColors.success,
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${timePercentage.toInt()}% of total time used',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTimeStatCard(
                  'Avg. per Question',
                  _formatDuration((timeSpent / totalQuestions).round()),
                  Icons.timer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeStatCard(
                  'Time Saved',
                  _formatDuration(totalTime - timeSpent),
                  Icons.schedule,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionCard(QuestionData question, int? userAnswer, int questionNumber, bool isCorrect, bool isUnanswered) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (isUnanswered) {
      statusColor = AppColors.warning;
      statusIcon = Icons.help_outline;
      statusText = 'Not Answered';
    } else if (isCorrect) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
      statusText = 'Correct';
    } else {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel;
      statusText = 'Incorrect';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusLG),
                topRight: Radius.circular(AppDimensions.radiusLG),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      questionNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.topic,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        question.difficultyLevel,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Options
                ...List.generate(question.options.length, (index) {
                  final option = question.options[index];
                  final isUserAnswer = userAnswer == index;
                  final isCorrectAnswer = question.correctAnswer == index;
                  
                  Color optionColor = AppColors.textSecondary;
                  Color backgroundColor = Colors.transparent;
                  
                  if (isCorrectAnswer) {
                    optionColor = AppColors.success;
                    backgroundColor = AppColors.success.withOpacity(0.1);
                  } else if (isUserAnswer && !isCorrect) {
                    optionColor = AppColors.error;
                    backgroundColor = AppColors.error.withOpacity(0.1);
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(AppDimensions.paddingMD),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      border: Border.all(
                        color: backgroundColor != Colors.transparent ? optionColor.withOpacity(0.3) : AppColors.neutral300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${String.fromCharCode(65 + index)}. ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: optionColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(color: optionColor),
                          ),
                        ),
                        if (isCorrectAnswer)
                          const Icon(Icons.check, color: AppColors.success, size: 20),
                        if (isUserAnswer && !isCorrect)
                          const Icon(Icons.close, color: AppColors.error, size: 20),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 16),
                
                // Explanation
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Explanation',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.explanation,
                        style: const TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.accent2;
    if (accuracy >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  void _shareResults() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _downloadReport() {
    // TODO: Implement download report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download report functionality coming soon!')),
    );
  }
}
