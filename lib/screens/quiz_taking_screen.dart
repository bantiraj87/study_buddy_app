import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/quiz_model.dart';
import '../data/mock_quiz_data.dart';
import 'quiz_results_screen.dart';

class QuizTakingScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final List<Map<String, dynamic>>? questions;

  const QuizTakingScreen({
    super.key,
    required this.quiz,
    this.questions,
  });

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  List<int?> _userAnswers = [];
  Timer? _timer;
  late int _timeRemaining; // in seconds
  bool _isQuizCompleted = false;
  late AnimationController _progressAnimationController;
  late AnimationController _questionAnimationController;
  late Animation<double> _questionSlideAnimation;

  // Mock questions data
  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
    _setupAnimations();
    _startTimer();
  }

  void _initializeQuiz() {
    _timeRemaining = (widget.quiz['timeLimit'] as int) * 60; // Convert to seconds
    
    // Use provided questions or generate mock questions from the data service
    if (widget.questions != null) {
      _questions = widget.questions!;
    } else {
      _questions = MockQuizData.getQuizQuestions(
        widget.quiz['subject'] ?? 'Science',
        widget.quiz['totalQuestions'] ?? 10,
      );
    }
    
    _userAnswers = List.filled(_questions.length, null);
  }

  // This method is no longer needed as we're using MockQuizData

  void _setupAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _questionSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _questionAnimationController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && !_isQuizCompleted) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _completeQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressAnimationController.dispose();
    _questionAnimationController.dispose();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswerIndex = answerIndex;
      _userAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() async {
    if (_selectedAnswerIndex == null) {
      _showAnswerRequiredDialog();
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      // Animate question transition
      await _questionAnimationController.reverse();
      
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
      });
      
      _progressAnimationController.animateTo(
        (_currentQuestionIndex + 1) / _questions.length,
      );
      
      await _questionAnimationController.forward();
    } else {
      _completeQuiz();
    }
  }

  void _previousQuestion() async {
    if (_currentQuestionIndex > 0) {
      await _questionAnimationController.reverse();
      
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
      });
      
      _progressAnimationController.animateTo(
        (_currentQuestionIndex + 1) / _questions.length,
      );
      
      await _questionAnimationController.forward();
    }
  }

  void _showAnswerRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Answer Required'),
        content: const Text('Please select an answer before proceeding.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _completeQuiz() {
    _timer?.cancel();
    setState(() {
      _isQuizCompleted = true;
    });

    // Calculate results
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }

    int totalTime = (widget.quiz['timeLimit'] as int) * 60;
    int timeSpent = totalTime - _timeRemaining;

    Map<String, dynamic> quizResult = {
      'quiz': widget.quiz,
      'questions': _questions,
      'userAnswers': _userAnswers,
      'correctAnswers': correctAnswers,
      'totalQuestions': _questions.length,
      'timeSpent': timeSpent,
      'totalTime': totalTime,
      'accuracy': (correctAnswers / _questions.length) * 100,
      'completedAt': DateTime.now(),
    };

    // Navigate to results screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(result: quizResult),
      ),
    );
  }

  void _showQuitConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text('Are you sure you want to quit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Quiz'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimeColor() {
    double progress = _timeRemaining / ((widget.quiz['timeLimit'] as int) * 60);
    if (progress > 0.5) return AppColors.success;
    if (progress > 0.25) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.quiz['title']),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showQuitConfirmDialog,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTimeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getTimeColor(), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: _getTimeColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_timeRemaining),
                  style: TextStyle(
                    color: _getTimeColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${((_currentQuestionIndex + 1) / _questions.length * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _progressAnimationController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / _questions.length,
                      backgroundColor: AppColors.neutral200,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Question Content
          Expanded(
            child: AnimatedBuilder(
              animation: _questionSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_questionSlideAnimation.value * MediaQuery.of(context).size.width, 0),
                  child: Opacity(
                    opacity: 1 - _questionSlideAnimation.value.abs(),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.paddingLG),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppDimensions.paddingLG),
                            decoration: BoxDecoration(
                              gradient: AppGradients.pastelBlueGradient,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                              boxShadow: AppShadows.soft,
                            ),
                            child: Text(
                              currentQuestion['question'],
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Options
                          ...List.generate(
                            (currentQuestion['options'] as List).length,
                            (index) {
                              final option = currentQuestion['options'][index];
                              final isSelected = _selectedAnswerIndex == index;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: GestureDetector(
                                  onTap: () => _selectAnswer(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(AppDimensions.paddingLG),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.1)
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.neutral300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected ? AppShadows.soft : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.neutral400,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            '${String.fromCharCode(65 + index)}. $option',
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.neutral200),
              ),
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _nextQuestion,
                    icon: Icon(
                      _currentQuestionIndex == _questions.length - 1
                          ? Icons.flag
                          : Icons.arrow_forward,
                    ),
                    label: Text(
                      _currentQuestionIndex == _questions.length - 1
                          ? 'Finish Quiz'
                          : 'Next Question',
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
