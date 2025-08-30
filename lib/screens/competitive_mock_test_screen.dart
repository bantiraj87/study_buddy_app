import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../data/competitive_exam_data.dart';
import 'competitive_test_result_screen.dart';

class CompetitiveMockTestScreen extends StatefulWidget {
  final MockTestSeries mockTest;

  const CompetitiveMockTestScreen({
    super.key,
    required this.mockTest,
  });

  @override
  State<CompetitiveMockTestScreen> createState() => _CompetitiveMockTestScreenState();
}

class _CompetitiveMockTestScreenState extends State<CompetitiveMockTestScreen>
    with TickerProviderStateMixin {
  
  // Test State
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  List<int?> _userAnswers = [];
  List<bool> _questionVisited = [];
  List<bool> _questionAnswered = [];
  Timer? _timer;
  late int _timeRemaining; // in seconds
  bool _isTestCompleted = false;
  bool _isTestStarted = false;
  
  // Questions and Test Data
  late List<QuestionData> _questions;
  late CompetitiveExamCategory _examCategory;
  
  // Animation Controllers
  late AnimationController _progressAnimationController;
  late AnimationController _questionAnimationController;
  late Animation<double> _questionSlideAnimation;
  
  // Question Navigation
  final PageController _questionPageController = PageController();
  bool _showQuestionPalette = false;

  @override
  void initState() {
    super.initState();
    _initializeTest();
    _setupAnimations();
    _showInstructions();
  }

  void _initializeTest() {
    _timeRemaining = widget.mockTest.timeLimit * 60; // Convert to seconds
    _examCategory = CompetitiveExamData.examCategories
        .firstWhere((cat) => cat.type == widget.mockTest.examType);
    
    // Generate questions for the mock test
    _questions = _generateQuestionsForTest();
    
    _userAnswers = List.filled(_questions.length, null);
    _questionVisited = List.filled(_questions.length, false);
    _questionAnswered = List.filled(_questions.length, false);
    
    // Mark first question as visited
    _questionVisited[0] = true;
  }

  List<QuestionData> _generateQuestionsForTest() {
    // This would normally come from the MockTestSeries.sections
    // For now, we'll generate questions based on the exam type
    final List<QuestionData> questions = [];
    
    switch (widget.mockTest.examType) {
      case CompetitiveExamType.ssc:
        questions.addAll(_generateSSCQuestions());
        break;
      case CompetitiveExamType.banking:
        questions.addAll(_generateBankingQuestions());
        break;
      case CompetitiveExamType.railway:
        questions.addAll(_generateRailwayQuestions());
        break;
      case CompetitiveExamType.police:
        questions.addAll(_generatePoliceQuestions());
        break;
      default:
        questions.addAll(_generateGeneralQuestions());
    }
    
    // Shuffle and take required number of questions
    questions.shuffle();
    return questions.take(widget.mockTest.totalQuestions).toList();
  }

  List<QuestionData> _generateSSCQuestions() {
    return [
      const QuestionData(
        id: 'ssc_1',
        question: 'Find the next number in the series: 2, 6, 12, 20, ?',
        options: ['30', '32', '28', '35'],
        correctAnswer: 0,
        explanation: 'The differences between consecutive terms are 4, 6, 8... Next difference would be 10, so 20 + 10 = 30',
        topic: 'Number Series',
        difficultyLevel: 'Easy',
        tags: ['reasoning', 'number-series'],
        language: 'English',
      ),
      const QuestionData(
        id: 'ssc_2',
        question: 'If CODING is written as DPEJOH, then FLOWER will be written as?',
        options: ['GMPXFS', 'GMPXFR', 'GNPXFS', 'GMPYFS'],
        correctAnswer: 0,
        explanation: 'Each letter is shifted by +1 position in the alphabet. F→G, L→M, O→P, W→X, E→F, R→S',
        topic: 'Coding-Decoding',
        difficultyLevel: 'Easy',
        tags: ['reasoning', 'coding'],
        language: 'English',
      ),
      const QuestionData(
        id: 'ssc_3',
        question: 'What is 25% of 80?',
        options: ['20', '25', '15', '30'],
        correctAnswer: 0,
        explanation: '25% of 80 = (25/100) × 80 = 20',
        topic: 'Percentage',
        difficultyLevel: 'Easy',
        tags: ['quantitative', 'percentage'],
        language: 'English',
      ),
      const QuestionData(
        id: 'ssc_4',
        question: 'Choose the correctly spelled word:',
        options: ['Accomodate', 'Accommodate', 'Acomodate', 'Acommodate'],
        correctAnswer: 1,
        explanation: 'Accommodate is the correct spelling with double "c" and double "m"',
        topic: 'Spelling',
        difficultyLevel: 'Easy',
        tags: ['english', 'spelling'],
        language: 'English',
      ),
      const QuestionData(
        id: 'ssc_5',
        question: 'Who is the current Prime Minister of India?',
        options: ['Rahul Gandhi', 'Narendra Modi', 'Amit Shah', 'Manmohan Singh'],
        correctAnswer: 1,
        explanation: 'Narendra Modi has been serving as the Prime Minister of India since 2014',
        topic: 'Current Affairs',
        difficultyLevel: 'Easy',
        tags: ['general-knowledge', 'politics'],
        language: 'English',
      ),
    ];
  }

  List<QuestionData> _generateBankingQuestions() {
    return [
      const QuestionData(
        id: 'bank_1',
        question: 'If A is to the north of B and C is to the east of B, in which direction is A with respect to C?',
        options: ['North-East', 'North-West', 'South-East', 'South-West'],
        correctAnswer: 1,
        explanation: 'A is north of B, C is east of B. So A is in the North-West direction with respect to C',
        topic: 'Direction Sense',
        difficultyLevel: 'Moderate',
        tags: ['reasoning', 'directions'],
        language: 'English',
      ),
      const QuestionData(
        id: 'bank_2',
        question: 'What is the compound interest on ₹10,000 for 2 years at 10% per annum?',
        options: ['₹2,000', '₹2,100', '₹2,200', '₹2,300'],
        correctAnswer: 1,
        explanation: 'CI = P[(1+r/100)^n - 1] = 10000[(1.1)^2 - 1] = 10000[1.21 - 1] = ₹2,100',
        topic: 'Compound Interest',
        difficultyLevel: 'Moderate',
        tags: ['quantitative', 'interest'],
        language: 'English',
      ),
      const QuestionData(
        id: 'bank_3',
        question: 'Choose the word that is most similar to "ABUNDANT":',
        options: ['Scarce', 'Plentiful', 'Limited', 'Rare'],
        correctAnswer: 1,
        explanation: 'Abundant means existing in large quantity, which is similar to plentiful',
        topic: 'Synonyms',
        difficultyLevel: 'Easy',
        tags: ['english', 'vocabulary'],
        language: 'English',
      ),
    ];
  }

  List<QuestionData> _generateRailwayQuestions() {
    return [
      const QuestionData(
        id: 'rail_1',
        question: 'What is the LCM of 12, 15, and 20?',
        options: ['60', '120', '180', '240'],
        correctAnswer: 0,
        explanation: 'LCM of 12, 15, 20 = 60 (Prime factorization method)',
        topic: 'LCM',
        difficultyLevel: 'Easy',
        tags: ['mathematics', 'lcm'],
        language: 'English',
      ),
      const QuestionData(
        id: 'rail_2',
        question: 'Which is the longest river in India?',
        options: ['Yamuna', 'Ganga', 'Godavari', 'Krishna'],
        correctAnswer: 1,
        explanation: 'The Ganga is the longest river in India with a length of about 2,525 km',
        topic: 'Indian Geography',
        difficultyLevel: 'Easy',
        tags: ['general-awareness', 'geography'],
        language: 'English',
      ),
    ];
  }

  List<QuestionData> _generatePoliceQuestions() {
    return [
      const QuestionData(
        id: 'police_1',
        question: 'If 5x + 3 = 18, then x = ?',
        options: ['2', '3', '4', '5'],
        correctAnswer: 1,
        explanation: '5x + 3 = 18, so 5x = 15, therefore x = 3',
        topic: 'Linear Equations',
        difficultyLevel: 'Easy',
        tags: ['mathematics', 'algebra'],
        language: 'English',
      ),
      const QuestionData(
        id: 'police_2',
        question: 'Who wrote the Indian National Anthem?',
        options: ['Rabindranath Tagore', 'Bankim Chandra Chattopadhyay', 'Mahatma Gandhi', 'Sarojini Naidu'],
        correctAnswer: 0,
        explanation: 'The Indian National Anthem "Jana Gana Mana" was written by Rabindranath Tagore',
        topic: 'Indian History',
        difficultyLevel: 'Easy',
        tags: ['general-knowledge', 'history'],
        language: 'English',
      ),
    ];
  }

  List<QuestionData> _generateGeneralQuestions() {
    return [
      const QuestionData(
        id: 'gen_1',
        question: 'What is the capital of Australia?',
        options: ['Sydney', 'Melbourne', 'Canberra', 'Brisbane'],
        correctAnswer: 2,
        explanation: 'Canberra is the capital city of Australia',
        topic: 'World Geography',
        difficultyLevel: 'Easy',
        tags: ['general-knowledge', 'geography'],
        language: 'English',
      ),
    ];
  }

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

  void _showInstructions() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _InstructionsDialog(
            mockTest: widget.mockTest,
            onStartTest: _startTest,
          ),
        );
      }
    });
  }

  void _startTest() {
    setState(() {
      _isTestStarted = true;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && !_isTestCompleted) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _completeTest();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressAnimationController.dispose();
    _questionAnimationController.dispose();
    _questionPageController.dispose();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswerIndex = answerIndex;
      _userAnswers[_currentQuestionIndex] = answerIndex;
      _questionAnswered[_currentQuestionIndex] = true;
    });
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      await _questionAnimationController.reverse();
      
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
        _questionVisited[_currentQuestionIndex] = true;
      });
      
      _questionPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      _progressAnimationController.animateTo(
        (_currentQuestionIndex + 1) / _questions.length,
      );
      
      await _questionAnimationController.forward();
    }
  }

  void _previousQuestion() async {
    if (_currentQuestionIndex > 0) {
      await _questionAnimationController.reverse();
      
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
        _questionVisited[_currentQuestionIndex] = true;
      });
      
      _questionPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      _progressAnimationController.animateTo(
        (_currentQuestionIndex + 1) / _questions.length,
      );
      
      await _questionAnimationController.forward();
    }
  }

  void _goToQuestion(int index) async {
    if (index != _currentQuestionIndex) {
      await _questionAnimationController.reverse();
      
      setState(() {
        _currentQuestionIndex = index;
        _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
        _questionVisited[_currentQuestionIndex] = true;
        _showQuestionPalette = false;
      });
      
      _questionPageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      _progressAnimationController.animateTo(
        (_currentQuestionIndex + 1) / _questions.length,
      );
      
      await _questionAnimationController.forward();
    } else {
      setState(() {
        _showQuestionPalette = false;
      });
    }
  }

  void _completeTest() {
    _timer?.cancel();
    setState(() {
      _isTestCompleted = true;
    });

    // Calculate results
    int correctAnswers = 0;
    int incorrectAnswers = 0;
    int unanswered = 0;
    double totalMarks = 0;
    
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == null) {
        unanswered++;
      } else if (_userAnswers[i] == _questions[i].correctAnswer) {
        correctAnswers++;
        totalMarks += 1; // Assuming each question carries 1 mark
      } else {
        incorrectAnswers++;
        if (widget.mockTest.hasNegativeMarking) {
          totalMarks -= widget.mockTest.negativeMarkingRatio;
        }
      }
    }

    int totalTime = widget.mockTest.timeLimit * 60;
    int timeSpent = totalTime - _timeRemaining;
    double accuracy = correctAnswers > 0 ? (correctAnswers / _questions.length) * 100 : 0;

    Map<String, dynamic> testResult = {
      'mockTest': widget.mockTest,
      'questions': _questions,
      'userAnswers': _userAnswers,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'unanswered': unanswered,
      'totalQuestions': _questions.length,
      'totalMarks': totalMarks,
      'timeSpent': timeSpent,
      'totalTime': totalTime,
      'accuracy': accuracy,
      'completedAt': DateTime.now(),
    };

    // Navigate to results screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CompetitiveTestResultScreen(result: testResult),
      ),
    );
  }

  void _showSubmitConfirmDialog() {
    final unansweredCount = _userAnswers.where((answer) => answer == null).length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to submit the test?'),
            const SizedBox(height: 12),
            Text('Questions Attempted: ${_questions.length - unansweredCount}/${_questions.length}'),
            if (unansweredCount > 0)
              Text(
                'Unanswered Questions: $unansweredCount',
                style: const TextStyle(color: AppColors.error),
              ),
            const SizedBox(height: 8),
            const Text('Note: You cannot change answers after submission.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Test'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeTest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  Color _getTimeColor() {
    double progress = _timeRemaining / (widget.mockTest.timeLimit * 60);
    if (progress > 0.5) return AppColors.success;
    if (progress > 0.25) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTestStarted) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.mockTest.title),
        elevation: 0,
        automaticallyImplyLeading: false,
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
          // Progress Bar and Question Navigator
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.neutral200),
              ),
            ),
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showQuestionPalette = !_showQuestionPalette;
                            });
                          },
                          icon: const Icon(Icons.grid_view, size: 20),
                          tooltip: 'Question Navigator',
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
          
          // Question Palette
          if (_showQuestionPalette)
            Container(
              height: 120,
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                border: Border(
                  bottom: BorderSide(color: AppColors.neutral200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question Navigator',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 10,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionNavButton(index);
                      },
                    ),
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
                          // Question Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppDimensions.paddingMD),
                            decoration: BoxDecoration(
                              color: _examCategory.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                              border: Border.all(color: _examCategory.color.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _examCategory.icon,
                                  color: _examCategory.color,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  currentQuestion.topic,
                                  style: TextStyle(
                                    color: _examCategory.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _examCategory.color,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    currentQuestion.difficultyLevel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
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
                              currentQuestion.question,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Options
                          ...List.generate(
                            currentQuestion.options.length,
                            (index) {
                              final option = currentQuestion.options[index];
                              final isSelected = _selectedAnswerIndex == index;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
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
                                          width: 28,
                                          height: 28,
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
                                                  size: 18,
                                                  color: Colors.white,
                                                )
                                              : Center(
                                                  child: Text(
                                                    String.fromCharCode(65 + index),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            option,
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
                          
                          const SizedBox(height: 24),
                          
                          // Negative Marking Warning
                          if (widget.mockTest.hasNegativeMarking)
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.paddingMD),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                                border: Border.all(color: AppColors.warning),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Negative marking: -${widget.mockTest.negativeMarkingRatio} marks for wrong answer',
                                      style: const TextStyle(
                                        color: AppColors.warning,
                                        fontSize: 12,
                                      ),
                                    ),
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
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _currentQuestionIndex == _questions.length - 1
                        ? _showSubmitConfirmDialog
                        : _nextQuestion,
                    icon: Icon(
                      _currentQuestionIndex == _questions.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                    ),
                    label: Text(
                      _currentQuestionIndex == _questions.length - 1
                          ? 'Submit Test'
                          : 'Next Question',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _showSubmitConfirmDialog,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNavButton(int index) {
    final isAnswered = _questionAnswered[index];
    final isVisited = _questionVisited[index];
    final isCurrent = _currentQuestionIndex == index;
    
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    
    if (isCurrent) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    } else if (isAnswered) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      textColor = AppColors.success;
      borderColor = AppColors.success;
    } else if (isVisited) {
      backgroundColor = AppColors.warning.withOpacity(0.1);
      textColor = AppColors.warning;
      borderColor = AppColors.warning;
    } else {
      backgroundColor = AppColors.neutral100;
      textColor = AppColors.textSecondary;
      borderColor = AppColors.neutral300;
    }
    
    return GestureDetector(
      onTap: () => _goToQuestion(index),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// Instructions Dialog
class _InstructionsDialog extends StatelessWidget {
  final MockTestSeries mockTest;
  final VoidCallback onStartTest;

  const _InstructionsDialog({
    required this.mockTest,
    required this.onStartTest,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Test Instructions'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mockTest.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructionItem('Total Questions: ${mockTest.totalQuestions}'),
            _buildInstructionItem('Time Duration: ${mockTest.timeLimit} minutes'),
            _buildInstructionItem('Total Marks: ${mockTest.totalMarks}'),
            if (mockTest.hasNegativeMarking)
              _buildInstructionItem(
                'Negative Marking: -${mockTest.negativeMarkingRatio} marks for each wrong answer',
                isWarning: true,
              ),
            _buildInstructionItem('Language: ${mockTest.language}'),
            const SizedBox(height: 16),
            const Text(
              'Important Points:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInstructionItem('• You can navigate between questions using the question palette'),
            _buildInstructionItem('• Green indicates answered questions'),
            _buildInstructionItem('• Orange indicates visited but not answered questions'),
            _buildInstructionItem('• Grey indicates not visited questions'),
            _buildInstructionItem('• Make sure to submit the test before time runs out'),
            if (mockTest.hasNegativeMarking)
              _buildInstructionItem(
                '• Be careful with wrong answers as they carry negative marks',
                isWarning: true,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onStartTest();
          },
          child: const Text('Start Test'),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String text, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isWarning ? AppColors.warning : AppColors.textSecondary,
        ),
      ),
    );
  }
}
