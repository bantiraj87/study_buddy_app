import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/quiz_model.dart';
import '../data/mock_quiz_data.dart';

class QuizCreationDialog extends StatefulWidget {
  const QuizCreationDialog({super.key});

  @override
  State<QuizCreationDialog> createState() => _QuizCreationDialogState();
}

class _QuizCreationDialogState extends State<QuizCreationDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Basic Info Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSubject = 'Mathematics';
  String _selectedDifficulty = 'Beginner';
  int _timeLimit = 30;
  bool _isPublic = false;
  bool _isRandomOrder = false;

  // Questions
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  
  // Current question being edited
  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (index) => TextEditingController());
  int _correctAnswerIndex = 0;

  final List<String> _subjects = [
    'Mathematics', 'Science', 'History', 'Languages', 
    'Literature', 'Technology', 'Business', 'Arts', 'Other'
  ];
  
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _addNewQuestion();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _questionController.dispose();
    _explanationController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add(QuizQuestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: '',
        options: ['', '', '', ''],
        correctAnswerIndex: 0,
        explanation: '',
        difficulty: _selectedDifficulty,
      ));
      _currentQuestionIndex = _questions.length - 1;
      _loadQuestionToEdit(_currentQuestionIndex);
    });
  }

  void _loadQuestionToEdit(int index) {
    final question = _questions[index];
    _questionController.text = question.question;
    _explanationController.text = question.explanation;
    for (int i = 0; i < _optionControllers.length; i++) {
      _optionControllers[i].text = i < question.options.length ? question.options[i] : '';
    }
    _correctAnswerIndex = question.correctAnswerIndex;
  }

  void _saveCurrentQuestion() {
    if (_currentQuestionIndex < _questions.length) {
      setState(() {
        _questions[_currentQuestionIndex] = QuizQuestion(
          id: _questions[_currentQuestionIndex].id,
          question: _questionController.text,
          options: _optionControllers.map((c) => c.text).toList(),
          correctAnswerIndex: _correctAnswerIndex,
          explanation: _explanationController.text,
          difficulty: _selectedDifficulty,
        );
      });
    }
  }

  void _deleteQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
        if (_currentQuestionIndex >= _questions.length) {
          _currentQuestionIndex = _questions.length - 1;
        }
        _loadQuestionToEdit(_currentQuestionIndex);
      });
    }
  }

  Future<void> _createQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      _showSnackBar('Please add at least one question');
      return;
    }

    _saveCurrentQuestion();

    // Validate all questions
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.question.trim().isEmpty) {
        _showSnackBar('Question ${i + 1} is empty');
        return;
      }
      if (question.options.any((option) => option.trim().isEmpty)) {
        _showSnackBar('Question ${i + 1} has empty options');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Create quiz model
      final quiz = QuizModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: _selectedSubject,
        difficulty: _selectedDifficulty,
        createdBy: 'User', // In real app, get from auth provider
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        questions: _questions,
        timeLimit: _timeLimit,
        isPublic: _isPublic,
        isRandomOrder: _isRandomOrder,
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop(quiz);
        _showSnackBar('Quiz "${_titleController.text}" created successfully!', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to create quiz: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Create Quiz'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _createQuiz,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Basic Info'),
              Tab(text: 'Questions'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBasicInfoTab(),
              _buildQuestionsTab(),
              _buildSettingsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Quiz Title *',
              hintText: 'Enter a catchy title for your quiz',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description *',
              hintText: 'Describe what this quiz covers and who it\'s for',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Subject and Difficulty Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                  ),
                  items: _subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSubject = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                  ),
                  items: _difficulties.map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(difficulty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDifficulty = value);
                    }
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Time Limit
          Text(
            'Time Limit: $_timeLimit minutes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _timeLimit.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            label: '$_timeLimit minutes',
            onChanged: (value) {
              setState(() => _timeLimit = value.round());
            },
          ),
          
          const SizedBox(height: 20),
          
          // Preview Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              gradient: AppGradients.pastelBlueGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _titleController.text.isEmpty ? 'Quiz Title' : _titleController.text,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _descriptionController.text.isEmpty 
                      ? 'Quiz description will appear here'
                      : _descriptionController.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildPreviewChip(_selectedSubject, AppColors.primary),
                    const SizedBox(width: 8),
                    _buildPreviewChip(_selectedDifficulty, AppColors.accent2),
                    const SizedBox(width: 8),
                    _buildPreviewChip('$_timeLimit min', AppColors.info),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuestionsTab() {
    return Column(
      children: [
        // Question Navigation
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _questions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _questions.length) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: _addNewQuestion,
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }

                    final isSelected = index == _currentQuestionIndex;
                    final question = _questions[index];
                    final isComplete = question.question.isNotEmpty && 
                                    question.options.every((option) => option.isNotEmpty);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          _saveCurrentQuestion();
                          setState(() => _currentQuestionIndex = index);
                          _loadQuestionToEdit(index);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primary 
                                : isComplete 
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.neutral200,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected 
                                ? null 
                                : Border.all(
                                    color: isComplete ? AppColors.success : AppColors.neutral300
                                  ),
                          ),
                          child: Center(
                            child: isComplete && !isSelected
                                ? const Icon(Icons.check, color: AppColors.success, size: 16)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isSelected 
                                          ? Colors.white 
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_questions.length > 1)
                IconButton(
                  onPressed: () => _deleteQuestion(_currentQuestionIndex),
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                ),
            ],
          ),
        ),
        
        const Divider(height: 1),
        
        // Question Editor
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Number and Title
                Row(
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_questions.length} question${_questions.length != 1 ? 's' : ''} total',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Question Text
                TextFormField(
                  controller: _questionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Question *',
                    hintText: 'Enter your question here',
                  ),
                  onChanged: (_) => _saveCurrentQuestion(),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  'Answer Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Answer Options
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: _correctAnswerIndex,
                          onChanged: (value) {
                            setState(() => _correctAnswerIndex = value!);
                            _saveCurrentQuestion();
                          },
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _optionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Option ${String.fromCharCode(65 + index)}',
                              hintText: 'Enter option text',
                              border: _correctAnswerIndex == index 
                                  ? const OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.success, width: 2),
                                    )
                                  : null,
                            ),
                            onChanged: (_) => _saveCurrentQuestion(),
                          ),
                        ),
                        if (_correctAnswerIndex == index)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.check_circle, color: AppColors.success),
                          ),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 20),
                
                // Explanation
                TextFormField(
                  controller: _explanationController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Explanation (Optional)',
                    hintText: 'Explain why this answer is correct',
                  ),
                  onChanged: (_) => _saveCurrentQuestion(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Public Quiz Setting
          Card(
            child: SwitchListTile(
              title: const Text('Make Quiz Public'),
              subtitle: const Text('Allow other users to discover and take this quiz'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Random Order Setting
          Card(
            child: SwitchListTile(
              title: const Text('Randomize Question Order'),
              subtitle: const Text('Questions will appear in random order for each attempt'),
              value: _isRandomOrder,
              onChanged: (value) => setState(() => _isRandomOrder = value),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quiz Summary
          Container(
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
                Text(
                  'Quiz Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Title', _titleController.text.isEmpty ? 'Not set' : _titleController.text),
                _buildSummaryRow('Subject', _selectedSubject),
                _buildSummaryRow('Difficulty', _selectedDifficulty),
                _buildSummaryRow('Questions', '${_questions.length}'),
                _buildSummaryRow('Time Limit', '$_timeLimit minutes'),
                _buildSummaryRow('Public', _isPublic ? 'Yes' : 'No'),
                _buildSummaryRow('Random Order', _isRandomOrder ? 'Yes' : 'No'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
