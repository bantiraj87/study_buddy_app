import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../../constants/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../models/quiz_model.dart';

class QuizGeneratorScreen extends StatefulWidget {
  const QuizGeneratorScreen({super.key});

  @override
  State<QuizGeneratorScreen> createState() => _QuizGeneratorScreenState();
}

class _QuizGeneratorScreenState extends State<QuizGeneratorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final AIService _aiService = AIService();
  
  List<QuizQuestion> _questions = [];
  bool _isLoading = false;
  bool _showQuiz = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isQuizComplete = false;
  String? _selectedAnswer;
  bool _showAnswer = false;
  int _numQuestions = 5;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _contentController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _generateQuiz() async {
    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('Please enter some content to generate quiz from');
      return;
    }

    setState(() {
      _isLoading = true;
      _showQuiz = false;
      _questions.clear();
    });

    try {
      final response = await _aiService.generateQuizQuestions(
        _contentController.text,
        numQuestions: _numQuestions,
      );
      
      if (response != null) {
        final jsonData = _parseJsonFromResponse(response);
        if (jsonData != null && jsonData['questions'] != null) {
          List<QuizQuestion> questions = [];
          for (var questionData in jsonData['questions']) {
            questions.add(QuizQuestion(
              question: questionData['question'] ?? '',
              options: List<String>.from(questionData['options'] ?? []),
              correctAnswer: questionData['correctAnswer'] ?? 'A',
              explanation: questionData['explanation'] ?? '',
            ));
          }
          
          setState(() {
            _questions = questions;
            _showQuiz = true;
            _isLoading = false;
            _currentQuestionIndex = 0;
            _score = 0;
            _isQuizComplete = false;
            _selectedAnswer = null;
            _showAnswer = false;
          });
          
          _fadeController.reset();
          _slideController.reset();
          _fadeController.forward();
          _slideController.forward();
          
          // Update user statistics
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.incrementQuizzesGenerated();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to generate quiz');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error generating quiz: ${e.toString()}');
    }
  }

  Map<String, dynamic>? _parseJsonFromResponse(String response) {
    try {
      // Clean the response
      String cleanResponse = response.trim();
      if (cleanResponse.contains('```json')) {
        cleanResponse = cleanResponse.replaceAll('```json', '').replaceAll('```', '');
      }
      cleanResponse = cleanResponse.trim();
      
      return json.decode(cleanResponse);
    } catch (e) {
      print('Error parsing JSON: $e');
      return null;
    }
  }

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        String content = '';
        
        if (file.extension == 'txt') {
          content = String.fromCharCodes(file.bytes!);
        } else {
          // For other file types, you might need additional parsing
          content = String.fromCharCodes(file.bytes!);
        }
        
        setState(() {
          _contentController.text = content;
        });
        
        _showSnackBar('File loaded successfully');
      }
    } catch (e) {
      _showSnackBar('Error loading file: ${e.toString()}');
    }
  }

  void _selectAnswer(String answer) {
    if (_showAnswer) return;
    
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    
    setState(() {
      _showAnswer = true;
      if (_selectedAnswer == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showAnswer = false;
      });
    } else {
      setState(() {
        _isQuizComplete = true;
      });
      
      // Update user statistics
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateQuizAccuracy(_score / _questions.length);
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _isQuizComplete = false;
      _selectedAnswer = null;
      _showAnswer = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Quiz Generator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          if (_showQuiz && !_isQuizComplete)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _showQuiz 
          ? _isQuizComplete 
              ? _buildQuizResults() 
              : _buildQuizQuestion()
          : _buildQuizSetup(),
    );
  }

  Widget _buildQuizSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInstructionCard(),
          const SizedBox(height: 20),
          _buildSettingsCard(),
          const SizedBox(height: 20),
          _buildInputSection(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.quiz,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'AI Quiz Generator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Create personalized quizzes from your study material. Perfect for testing your knowledge and exam preparation.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quiz Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Number of Questions: ',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _numQuestions.toDouble(),
                  min: 3,
                  max: 15,
                  divisions: 12,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _numQuestions = value.round();
                    });
                  },
                ),
              ),
              Text(
                '$_numQuestions',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.library_books, color: AppTheme.textPrimary),
                const SizedBox(width: 8),
                const Text(
                  'Study Material',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _uploadFile,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Upload File'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _contentController,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: 'Paste your study material here or upload a file...\n\nExample:\n- Chapter content\n- Lecture notes\n- Reading material\n- Key concepts',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      decoration: BoxDecoration(
        gradient: _isLoading ? null : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isLoading ? null : AppTheme.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateQuiz,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading ? Colors.grey[300] : Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Generating Quiz...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Generate Quiz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuizQuestion() {
    if (_questions.isEmpty) return Container();
    
    final question = _questions[_currentQuestionIndex];
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    final optionLetter = option.split(')')[0];
                    final isSelected = _selectedAnswer == optionLetter;
                    final isCorrect = optionLetter == question.correctAnswer;
                    
                    Color? backgroundColor;
                    Color? borderColor;
                    
                    if (_showAnswer) {
                      if (isCorrect) {
                        backgroundColor = Colors.green[50];
                        borderColor = Colors.green;
                      } else if (isSelected && !isCorrect) {
                        backgroundColor = Colors.red[50];
                        borderColor = Colors.red;
                      }
                    } else if (isSelected) {
                      backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
                      borderColor = AppTheme.primaryColor;
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _selectAnswer(optionLetter),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor ?? Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderColor ?? Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              color: borderColor ?? AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Explanation (if answer is shown)
              if (_showAnswer && question.explanation.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Explanation',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.explanation,
                        style: TextStyle(
                          color: Colors.blue[800],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Action Button
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.buttonShadow,
                ),
                child: ElevatedButton(
                  onPressed: _selectedAnswer != null 
                      ? (_showAnswer ? _nextQuestion : _submitAnswer)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _showAnswer 
                        ? (_currentQuestionIndex < _questions.length - 1 ? 'Next Question' : 'Finish Quiz')
                        : 'Submit Answer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizResults() {
    final percentage = (_score / _questions.length * 100).round();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Icon(
                    percentage >= 80 ? Icons.emoji_events : 
                    percentage >= 60 ? Icons.thumb_up : Icons.trending_up,
                    size: 60,
                    color: percentage >= 80 ? Colors.amber : 
                           percentage >= 60 ? Colors.green : AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quiz Complete!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Score: $_score/${_questions.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 80 ? Colors.green : 
                             percentage >= 60 ? Colors.orange : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    percentage >= 80 ? 'Excellent work! 🎉' :
                    percentage >= 60 ? 'Good job! Keep it up! 👏' :
                    'Keep studying! You can do better! 💪',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _restartQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retake Quiz',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.buttonShadow,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showQuiz = false;
                          _questions.clear();
                          _contentController.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'New Quiz',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}
