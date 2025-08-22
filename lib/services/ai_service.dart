import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/quiz_model.dart';
import '../models/flashcard_model.dart';
import '../models/study_plan_model.dart';

class AIService {
  static const String _apiKey = 'AIzaSyAQIKPWvVamZngYL5Hb2O1vfbUrPDT9enA';
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  // Generate quiz questions from content
  Future<String?> generateQuizQuestions(String content, {int numQuestions = 5}) async {
    try {
      final prompt = '''
Create $numQuestions multiple-choice quiz questions based on the following content:

$content

Format your response as JSON with this structure:
{
  "questions": [
    {
      "question": "Question text here?",
      "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
      "correctAnswer": "A",
      "explanation": "Brief explanation of the correct answer"
    }
  ]
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error generating quiz questions: $e');
      return null;
    }
  }

  // Generate flashcards from content
  Future<String?> generateFlashcards(String content, {int numCards = 10}) async {
    try {
      final prompt = '''
Create $numCards flashcards based on the following content:

$content

Format your response as JSON with this structure:
{
  "flashcards": [
    {
      "front": "Question or term",
      "back": "Answer or definition",
      "difficulty": "easy|medium|hard"
    }
  ]
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error generating flashcards: $e');
      return null;
    }
  }

  // Summarize notes/content
  Future<String?> summarizeContent(String content) async {
    try {
      final prompt = '''
Please provide a clear and concise summary of the following content:

$content

Make the summary easy to understand and highlight the key points.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error summarizing content: $e');
      return null;
    }
  }

  // Answer questions about study content
  Future<String?> answerQuestion(String question, String context) async {
    try {
      final prompt = '''
Based on the following context, please answer the question:

Context: $context

Question: $question

Provide a clear, helpful answer based on the context provided.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error answering question: $e');
      return null;
    }
  }

  // Generate study plan
  Future<String?> generateStudyPlan(String subject, String timeframe, String difficulty) async {
    try {
      final prompt = '''
Create a structured study plan for the following:
- Subject: $subject
- Timeframe: $timeframe
- Difficulty Level: $difficulty

Include:
1. Daily/weekly goals
2. Key topics to cover
3. Recommended study methods
4. Practice activities
5. Milestones and checkpoints

Format the response in a clear, organized manner.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error generating study plan: $e');
      return null;
    }
  }

  // Explain concepts in simple terms
  Future<String?> explainConcept(String concept, {String level = 'beginner'}) async {
    try {
      final prompt = '''
Please explain the concept "$concept" in simple terms suitable for a $level level student.

Use:
- Clear, easy-to-understand language
- Examples or analogies when helpful
- Break down complex ideas into smaller parts
- Practical applications if relevant
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error explaining concept: $e');
      return null;
    }
  }

  // Generate daily challenges
  Future<Map<String, dynamic>?> generateDailyChallenge(String subject) async {
    try {
      final prompt = '''
Create a daily study challenge for the subject: $subject

Format as JSON:
{
  "title": "Challenge title",
  "description": "What the user needs to do",
  "type": "quiz|flashcards|summary|research",
  "points": 50,
  "timeEstimate": "15 minutes",
  "content": "Specific content or task description"
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      if (response.text != null) {
        final cleanText = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        return json.decode(cleanText);
      }
      return null;
    } catch (e) {
      print('Error generating daily challenge: $e');
      return null;
    }
  }

  // Get personalized study recommendations
  Future<List<String>?> getStudyRecommendations(Map<String, dynamic> userProgress) async {
    try {
      final prompt = '''
Based on this user's study progress, provide 3-5 personalized study recommendations:

${json.encode(userProgress)}

Format as a JSON array of recommendation strings:
["Recommendation 1", "Recommendation 2", "Recommendation 3"]
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      if (response.text != null) {
        final cleanText = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final List<dynamic> recommendations = json.decode(cleanText);
        return recommendations.cast<String>();
      }
      return null;
    } catch (e) {
      print('Error getting study recommendations: $e');
      return null;
    }
  }

  // Create topic outlines
  Future<String?> createTopicOutline(String topic, String depth) async {
    try {
      final prompt = '''
Create a comprehensive outline for the topic: "$topic"
Depth level: $depth

Include:
- Main sections and subsections
- Key concepts to understand
- Important terms and definitions
- Suggested learning sequence
- Practice opportunities

Format as a clear, hierarchical outline.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error creating topic outline: $e');
      return null;
    }
  }

  // Generate practice problems
  Future<String?> generatePracticeProblems(String topic, String difficulty, int count) async {
    try {
      final prompt = '''
Generate $count practice problems for the topic: "$topic"
Difficulty: $difficulty

For each problem, include:
- Clear problem statement
- Step-by-step solution
- Key concepts being tested
- Common mistakes to avoid

Format in a clear, educational manner.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('Error generating practice problems: $e');
      return null;
    }
  }
}
