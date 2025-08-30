import 'package:flutter/material.dart';
import 'dart:math';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import 'quiz_taking_screen.dart';

class QuizResultsScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const QuizResultsScreen({
    super.key,
    required this.result,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late AnimationController _chartAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.result['accuracy'] / 100,
    ).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _chartAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _chartAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  Color _getScoreColor(double accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _getPerformanceMessage(double accuracy) {
    if (accuracy >= 90) return "Outstanding! 🌟";
    if (accuracy >= 80) return "Excellent work! 🎉";
    if (accuracy >= 70) return "Good job! 👍";
    if (accuracy >= 60) return "Not bad! 👌";
    if (accuracy >= 50) return "Keep practicing! 💪";
    return "Don't give up! 🚀";
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.result['quiz'] as Map<String, dynamic>;
    final questions = widget.result['questions'] as List<Map<String, dynamic>>;
    final userAnswers = widget.result['userAnswers'] as List<int?>;
    final correctAnswers = widget.result['correctAnswers'] as int;
    final totalQuestions = widget.result['totalQuestions'] as int;
    final accuracy = widget.result['accuracy'] as double;
    final timeSpent = widget.result['timeSpent'] as int;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Quiz Results',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Column(
                children: [
                  // Score Card
                  _buildScoreCard(quiz, accuracy, correctAnswers, totalQuestions),
                  
                  const SizedBox(height: 24),
                  
                  // Stats Cards
                  _buildStatsRow(timeSpent, totalQuestions),
                  
                  const SizedBox(height: 24),
                  
                  // Performance Chart
                  _buildPerformanceChart(correctAnswers, totalQuestions),
                  
                  const SizedBox(height: 24),
                  
                  // Question Review
                  _buildQuestionReview(questions, userAnswers),
                  
                  const SizedBox(height: 32),
                  
              // Performance Analysis
              _buildPerformanceAnalysis(),
              
              const SizedBox(height: 24),
              
              // Study Recommendations
              _buildStudyRecommendations(),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButtons(quiz),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(Map<String, dynamic> quiz, double accuracy, int correct, int total) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getScoreColor(accuracy).withOpacity(0.1),
                _getScoreColor(accuracy).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            border: Border.all(
              color: _getScoreColor(accuracy).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: AppShadows.large,
          ),
          child: Column(
            children: [
              Text(
                quiz['title'],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Circular Score Display
              SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  children: [
                    // Background Circle
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        backgroundColor: AppColors.neutral200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.neutral200,
                        ),
                      ),
                    ),
                    // Progress Circle
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: _scoreAnimation.value,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(accuracy),
                        ),
                      ),
                    ),
                    // Score Text
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(_scoreAnimation.value * 100).toInt()}%',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(accuracy),
                              fontSize: 36,
                            ),
                          ),
                          Text(
                            '$correct/$total',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                _getPerformanceMessage(accuracy),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getScoreColor(accuracy),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(int timeSpent, int totalQuestions) {
    return AnimatedBuilder(
      animation: _chartAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _chartAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _chartAnimation.value)),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    Icons.timer,
                    'Time Spent',
                    _formatTime(timeSpent),
                    AppGradients.pastelBlueGradient,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    Icons.speed,
                    'Avg per Question',
                    _formatTime((timeSpent / totalQuestions).round()),
                    AppGradients.pastelGreenGradient,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(int correct, int total) {
    int incorrect = total - correct;
    
    return AnimatedBuilder(
      animation: _chartAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _chartAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _chartAnimation.value)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                children: [
                  Text(
                    'Performance Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Custom Bar Chart
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarChartItem(
                          'Correct',
                          correct,
                          total,
                          AppColors.success,
                          _chartAnimation.value,
                        ),
                        _buildBarChartItem(
                          'Incorrect',
                          incorrect,
                          total,
                          AppColors.error,
                          _chartAnimation.value,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChartItem(String label, int value, int total, Color color, double animation) {
    double percentage = value / total;
    double height = 150 * percentage * animation;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 1200),
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionReview(List<Map<String, dynamic>> questions, List<int?> userAnswers) {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _listAnimationController.value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - _listAnimationController.value)),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLG),
                    child: Row(
                      children: [
                        Icon(
                          Icons.quiz,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Question Review',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: questions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      final userAnswer = userAnswers[index];
                      final correctAnswer = question['correctAnswer'];
                      final isCorrect = userAnswer == correctAnswer;
                      
                      return ExpansionTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCorrect ? AppColors.success : AppColors.error,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          'Question ${index + 1}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          question['question'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppDimensions.paddingMD),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Question
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                                  ),
                                  child: Text(
                                    question['question'],
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Options
                                ...List.generate((question['options'] as List).length, (optionIndex) {
                                  final option = question['options'][optionIndex];
                                  final isUserAnswer = userAnswer == optionIndex;
                                  final isCorrectAnswer = correctAnswer == optionIndex;
                                  
                                  Color backgroundColor = AppColors.surface;
                                  Color textColor = AppColors.textPrimary;
                                  IconData? icon;
                                  
                                  if (isCorrectAnswer) {
                                    backgroundColor = AppColors.success.withOpacity(0.1);
                                    textColor = AppColors.success;
                                    icon = Icons.check_circle;
                                  } else if (isUserAnswer && !isCorrect) {
                                    backgroundColor = AppColors.error.withOpacity(0.1);
                                    textColor = AppColors.error;
                                    icon = Icons.cancel;
                                  }
                                  
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(AppDimensions.paddingMD),
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                                      border: isUserAnswer || isCorrectAnswer
                                          ? Border.all(
                                              color: isCorrectAnswer ? AppColors.success : AppColors.error,
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        if (icon != null) ...[
                                          Icon(icon, color: textColor, size: 20),
                                          const SizedBox(width: 12),
                                        ],
                                        Expanded(
                                          child: Text(
                                            '${String.fromCharCode(65 + optionIndex)}. $option',
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: (isUserAnswer || isCorrectAnswer)
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                
                                // Explanation
                                if (question['explanation'] != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(AppDimensions.paddingMD),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                                      border: Border.all(
                                        color: AppColors.info.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.lightbulb,
                                              color: AppColors.info,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Explanation',
                                              style: TextStyle(
                                                color: AppColors.info,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          question['explanation'],
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceAnalysis() {
    final correctAnswers = widget.result['correctAnswers'] as int;
    final totalQuestions = widget.result['totalQuestions'] as int;
    final accuracy = widget.result['accuracy'] as double;
    final timeSpent = widget.result['timeSpent'] as int;
    final totalTime = widget.result['totalTime'] as int;
    
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _listAnimationController.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _listAnimationController.value)),
            child: Container(
              width: double.infinity,
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
                        Icons.analytics,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Performance Analysis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Metrics Grid
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.5,
                    children: [
                      _buildMetricCard(
                        'Accuracy',
                        '${accuracy.toStringAsFixed(1)}%',
                        Icons.gps_fixed,
                        _getScoreColor(accuracy),
                      ),
                      _buildMetricCard(
                        'Speed',
                        '${(timeSpent / totalQuestions / 60).toStringAsFixed(1)} min/Q',
                        Icons.speed,
                        AppColors.info,
                      ),
                      _buildMetricCard(
                        'Correct',
                        '$correctAnswers/$totalQuestions',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                      _buildMetricCard(
                        'Time Used',
                        '${(timeSpent / totalTime * 100).toInt()}%',
                        Icons.timer,
                        AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyRecommendations() {
    final accuracy = widget.result['accuracy'] as double;
    final quiz = widget.result['quiz'] as Map<String, dynamic>;
    
    String recommendation;
    IconData recommendationIcon;
    Color recommendationColor;
    
    if (accuracy >= 90) {
      recommendation = "Excellent work! You've mastered this topic. Consider exploring advanced concepts or helping others learn.";
      recommendationIcon = Icons.emoji_events;
      recommendationColor = AppColors.success;
    } else if (accuracy >= 75) {
      recommendation = "Good job! Review the questions you missed and practice similar problems to strengthen your understanding.";
      recommendationIcon = Icons.thumb_up;
      recommendationColor = AppColors.info;
    } else if (accuracy >= 60) {
      recommendation = "You're on the right track! Focus on reviewing the fundamental concepts and take more practice quizzes.";
      recommendationIcon = Icons.trending_up;
      recommendationColor = AppColors.warning;
    } else {
      recommendation = "Don't give up! Review the study materials thoroughly and consider seeking additional help or resources.";
      recommendationIcon = Icons.school;
      recommendationColor = AppColors.error;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: recommendationColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: recommendationColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                recommendationIcon,
                color: recommendationColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Study Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: recommendationColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            recommendation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Suggested Actions
          Wrap(
            spacing: 8,
            children: [
              _buildActionChip('Study ${quiz['subject']}', Icons.book, AppColors.primary),
              _buildActionChip('Practice More', Icons.fitness_center, AppColors.info),
              if (accuracy < 75) _buildActionChip('Review Mistakes', Icons.error_outline, AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon, Color color) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      onPressed: () {
        // TODO: Implement action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label feature coming soon!')),
        );
      },
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> quiz) {
    final accuracy = widget.result['accuracy'] as double;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _retakeQuiz,
                icon: const Icon(Icons.refresh),
                label: const Text('Retake Quiz'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareResults,
                icon: const Icon(Icons.share),
                label: const Text('Share Results'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Save results
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Results saved to your history!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark),
                label: const Text('Save Results'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _retakeQuiz() {
    final quiz = widget.result['quiz'] as Map<String, dynamic>;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retake Quiz'),
        content: const Text('Are you sure you want to retake this quiz? Your current results will be replaced.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizTakingScreen(quiz: quiz),
                ),
              );
            },
            child: const Text('Retake'),
          ),
        ],
      ),
    );
  }

  void _shareResults() {
    final accuracy = widget.result['accuracy'] as double;
    final quiz = widget.result['quiz'] as Map<String, dynamic>;
    final correctAnswers = widget.result['correctAnswers'] as int;
    final totalQuestions = widget.result['totalQuestions'] as int;
    
    final shareText = '''🎯 Quiz Results!

Quiz: ${quiz['title']}
Score: $correctAnswers/$totalQuestions (${accuracy.toStringAsFixed(1)}%)
${_getPerformanceMessage(accuracy)}

Taken on Study Buddy App 📚''';
    
    // TODO: Implement actual sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share text copied: $shareText'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
