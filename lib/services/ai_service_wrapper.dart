import '../services/ai_service.dart';

class AIServiceWrapper {
  static final AIService _aiService = AIService();
  static bool _forceDisableAI = true; // Temporarily disable AI to prevent quota errors
  
  static bool get isAIEnabled => !_forceDisableAI && _aiService.isAvailable;
  
  static void enableAI() {
    _forceDisableAI = false;
  }
  
  static void disableAI() {
    _forceDisableAI = true;
  }
  
  // Safe wrappers for AI methods that return fallbacks when disabled
  static Future<String?> generateQuizQuestions(String content, {int numQuestions = 5}) async {
    if (_forceDisableAI) {
      return _aiService.getFallbackQuizQuestions(numQuestions);
    }
    return await _aiService.generateQuizQuestions(content, numQuestions: numQuestions);
  }
  
  static Future<String?> summarizeContent(String content) async {
    if (_forceDisableAI) {
      return _aiService.getFallbackSummary();
    }
    return await _aiService.summarizeContent(content);
  }
  
  static Future<String?> generateStudyPlan(String subject, String timeframe, String difficulty) async {
    if (_forceDisableAI) {
      return _aiService.getFallbackStudyPlan(subject, timeframe, difficulty);
    }
    return await _aiService.generateStudyPlan(subject, timeframe, difficulty);
  }
  
  static Future<Map<String, dynamic>?> generateDailyChallenge(String subject) async {
    if (_forceDisableAI) {
      return _aiService.getFallbackDailyChallenge(subject);
    }
    return await _aiService.generateDailyChallenge(subject);
  }
  
  static Future<List<String>?> getStudyRecommendations(Map<String, dynamic> userProgress) async {
    if (_forceDisableAI) {
      return _aiService.getFallbackRecommendations();
    }
    return await _aiService.getStudyRecommendations(userProgress);
  }
  
  static Future<String?> answerQuestion(String question, String context) async {
    if (_forceDisableAI) {
      return "AI-powered question answering is temporarily unavailable. Please consult your study materials or ask a teacher for help with this question.";
    }
    return await _aiService.answerQuestion(question, context);
  }
  
  static Future<String?> explainConcept(String concept, {String level = 'beginner'}) async {
    if (_forceDisableAI) {
      return "AI-powered concept explanations are temporarily unavailable. Please refer to your textbooks or online resources for information about '$concept'.";
    }
    return await _aiService.explainConcept(concept, level: level);
  }
}
