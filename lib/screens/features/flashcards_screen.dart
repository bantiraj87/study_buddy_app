import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../../constants/app_theme.dart';
import '../../providers/user_provider.dart';
// Simple flashcard model for this screen
class Flashcard {
  final String id;
  final String front;
  final String back;
  final FlashcardDifficulty difficulty;
  final String studyPackId;
  final DateTime createdAt;
  final DateTime? lastReviewed;
  final DateTime nextReview;
  final double easeFactor;
  final int interval;
  final int repetitions;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.difficulty,
    required this.studyPackId,
    required this.createdAt,
    this.lastReviewed,
    required this.nextReview,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
  });

  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
    FlashcardDifficulty? difficulty,
    String? studyPackId,
    DateTime? createdAt,
    DateTime? lastReviewed,
    DateTime? nextReview,
    double? easeFactor,
    int? interval,
    int? repetitions,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      difficulty: difficulty ?? this.difficulty,
      studyPackId: studyPackId ?? this.studyPackId,
      createdAt: createdAt ?? this.createdAt,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
    );
  }
}

enum FlashcardDifficulty {
  easy,
  medium,
  hard,
}

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final AIService _aiService = AIService();
  
  List<Flashcard> _flashcards = [];
  bool _isLoading = false;
  bool _showFlashcards = false;
  int _currentCardIndex = 0;
  bool _showAnswer = false;
  int _numCards = 10;
  
  late AnimationController _flipController;
  late AnimationController _slideController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _contentController.dispose();
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _generateFlashcards() async {
    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('Please enter some content to generate flashcards from');
      return;
    }

    setState(() {
      _isLoading = true;
      _showFlashcards = false;
      _flashcards.clear();
    });

    try {
      final response = await _aiService.generateFlashcards(
        _contentController.text,
        numCards: _numCards,
      );
      
      if (response != null) {
        final jsonData = _parseJsonFromResponse(response);
        if (jsonData != null && jsonData['flashcards'] != null) {
          List<Flashcard> flashcards = [];
          for (var cardData in jsonData['flashcards']) {
            flashcards.add(Flashcard(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              front: cardData['front'] ?? '',
              back: cardData['back'] ?? '',
              difficulty: _parseDifficulty(cardData['difficulty']),
              studyPackId: '',
              createdAt: DateTime.now(),
              lastReviewed: null,
              nextReview: DateTime.now(),
              easeFactor: 2.5,
              interval: 1,
              repetitions: 0,
            ));
          }
          
          setState(() {
            _flashcards = flashcards;
            _showFlashcards = true;
            _isLoading = false;
            _currentCardIndex = 0;
            _showAnswer = false;
          });
          
          _slideController.reset();
          _slideController.forward();
          
          // Update user statistics
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.incrementFlashcardsGenerated();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to generate flashcards');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error generating flashcards: ${e.toString()}');
    }
  }

  FlashcardDifficulty _parseDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return FlashcardDifficulty.easy;
      case 'medium':
        return FlashcardDifficulty.medium;
      case 'hard':
        return FlashcardDifficulty.hard;
      default:
        return FlashcardDifficulty.medium;
    }
  }

  Map<String, dynamic>? _parseJsonFromResponse(String response) {
    try {
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

  void _flipCard() {
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _nextCard() {
    if (_currentCardIndex < _flashcards.length - 1) {
      _flipController.reset();
      _slideController.reset();
      
      setState(() {
        _currentCardIndex++;
        _showAnswer = false;
      });
      
      _slideController.forward();
    } else {
      _showCompletionDialog();
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      _flipController.reset();
      _slideController.reset();
      
      setState(() {
        _currentCardIndex--;
        _showAnswer = false;
      });
      
      _slideController.forward();
    }
  }

  void _shuffleCards() {
    setState(() {
      _flashcards.shuffle(Random());
      _currentCardIndex = 0;
      _showAnswer = false;
    });
    _flipController.reset();
    _slideController.reset();
    _slideController.forward();
    _showSnackBar('Flashcards shuffled!');
  }

  void _markDifficulty(FlashcardDifficulty difficulty) {
    if (_currentCardIndex < _flashcards.length) {
      setState(() {
        _flashcards[_currentCardIndex] = _flashcards[_currentCardIndex].copyWith(
          difficulty: difficulty,
          lastReviewed: DateTime.now(),
        );
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.celebration, color: AppTheme.primaryColor),
              SizedBox(width: 12),
              Text('Congratulations!'),
            ],
          ),
          content: const Text(
            'You\'ve completed all flashcards! Great job on your study session.',
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartFlashcards();
              },
              child: const Text('Study Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _showFlashcards = false;
                  _flashcards.clear();
                  _contentController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Create New Set', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _restartFlashcards() {
    setState(() {
      _currentCardIndex = 0;
      _showAnswer = false;
    });
    _flipController.reset();
    _slideController.reset();
    _slideController.forward();
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
          'AI Flashcards',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          if (_showFlashcards) ...[
            IconButton(
              icon: const Icon(Icons.shuffle),
              onPressed: _shuffleCards,
              tooltip: 'Shuffle Cards',
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentCardIndex + 1}/${_flashcards.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      body: _showFlashcards ? _buildFlashcardView() : _buildSetupView(),
    );
  }

  Widget _buildSetupView() {
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
                  Icons.style,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'AI Flashcard Generator',
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
            'Transform your study material into interactive flashcards. Perfect for memorization and active recall practice.',
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
            'Flashcard Settings',
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
                'Number of Cards: ',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _numCards.toDouble(),
                  min: 5,
                  max: 25,
                  divisions: 20,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _numCards = value.round();
                    });
                  },
                ),
              ),
              Text(
                '$_numCards',
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
                hintText: 'Paste your study material here or upload a file...\n\nExample:\n- Definitions and terms\n- Key concepts\n- Important facts\n- Formulas and equations',
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
        onPressed: _isLoading ? null : _generateFlashcards,
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
                    'Generating Flashcards...',
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
                  Icon(Icons.style, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Generate Flashcards',
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

  Widget _buildFlashcardView() {
    if (_flashcards.isEmpty) return Container();
    
    final flashcard = _flashcards[_currentCardIndex];
    
    return Column(
      children: [
        // Progress indicator
        Container(
          margin: const EdgeInsets.all(20),
          child: LinearProgressIndicator(
            value: (_currentCardIndex + 1) / _flashcards.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            minHeight: 6,
          ),
        ),
        
        // Flashcard
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final isFlipped = _flipAnimation.value >= 0.5;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_flipAnimation.value * pi),
                        child: Container(
                          width: double.infinity,
                          height: 400,
                          decoration: BoxDecoration(
                            gradient: isFlipped 
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.green[100]!, Colors.green[50]!],
                                  )
                                : AppTheme.cardGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isFlipped ? Icons.lightbulb : Icons.help_outline,
                                    color: isFlipped ? Colors.green : AppTheme.primaryColor,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    isFlipped ? 'Answer' : 'Question',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isFlipped ? Colors.green[700] : AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateY(isFlipped ? pi : 0),
                                    child: Text(
                                      isFlipped ? flashcard.back : flashcard.front,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        height: 1.4,
                                        color: AppTheme.textPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Tap to ${isFlipped ? 'flip back' : 'reveal answer'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Difficulty buttons (shown when answer is visible)
        if (_showAnswer) ...[
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDifficultyButton(
                  'Easy',
                  Icons.sentiment_very_satisfied,
                  Colors.green,
                  FlashcardDifficulty.easy,
                ),
                _buildDifficultyButton(
                  'Medium',
                  Icons.sentiment_neutral,
                  Colors.orange,
                  FlashcardDifficulty.medium,
                ),
                _buildDifficultyButton(
                  'Hard',
                  Icons.sentiment_very_dissatisfied,
                  Colors.red,
                  FlashcardDifficulty.hard,
                ),
              ],
            ),
          ),
        ],
        
        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (_currentCardIndex > 0)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _previousCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back),
                        SizedBox(width: 8),
                        Text('Previous', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              if (_currentCardIndex > 0) const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.buttonShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: _nextCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentCardIndex < _flashcards.length - 1 ? 'Next' : 'Finish',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentCardIndex < _flashcards.length - 1 
                              ? Icons.arrow_forward 
                              : Icons.check,
                          color: Colors.white,
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
    );
  }

  Widget _buildDifficultyButton(
    String label,
    IconData icon,
    Color color,
    FlashcardDifficulty difficulty,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            _markDifficulty(difficulty);
            _nextCard();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: color.withOpacity(0.3)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
