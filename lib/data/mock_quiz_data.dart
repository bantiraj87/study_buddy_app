enum QuizCategory {
  academic,
  professional,
  fun,
  certification,
  competitive,
  trending,
}

class QuizSubcategory {
  final String id;
  final String name;
  final String description;
  final QuizCategory category;
  final String iconName;
  
  const QuizSubcategory({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconName,
  });
}

class QuizAnalytics {
  final int totalAttempts;
  final double averageScore;
  final double averageTime;
  final Map<String, int> difficultyDistribution;
  final List<String> popularTags;
  final double userSatisfactionRating;
  
  const QuizAnalytics({
    required this.totalAttempts,
    required this.averageScore,
    required this.averageTime,
    required this.difficultyDistribution,
    required this.popularTags,
    required this.userSatisfactionRating,
  });
}

class MockQuizData {
  // Quiz categories and subcategories
  static const List<QuizSubcategory> _subcategories = [
    QuizSubcategory(
      id: 'stem',
      name: 'STEM',
      description: 'Science, Technology, Engineering, and Mathematics',
      category: QuizCategory.academic,
      iconName: 'science',
    ),
    QuizSubcategory(
      id: 'humanities',
      name: 'Humanities',
      description: 'History, Literature, Philosophy, and Arts',
      category: QuizCategory.academic,
      iconName: 'menu_book',
    ),
    QuizSubcategory(
      id: 'languages',
      name: 'Languages',
      description: 'World languages and linguistics',
      category: QuizCategory.academic,
      iconName: 'translate',
    ),
    QuizSubcategory(
      id: 'business',
      name: 'Business & Finance',
      description: 'Business knowledge and financial literacy',
      category: QuizCategory.professional,
      iconName: 'business',
    ),
    QuizSubcategory(
      id: 'tech_certifications',
      name: 'Tech Certifications',
      description: 'IT and software development certifications',
      category: QuizCategory.certification,
      iconName: 'verified',
    ),
    QuizSubcategory(
      id: 'general_knowledge',
      name: 'General Knowledge',
      description: 'Mixed topics and trivia',
      category: QuizCategory.fun,
      iconName: 'lightbulb',
    ),
  ];

  // Enhanced featured quizzes with more comprehensive data
  static List<Map<String, dynamic>> getFeaturedQuizzes() {
    return [
      {
        'id': 'featured_1',
        'title': 'Advanced Mathematics Mastery',
        'subject': 'Mathematics',
        'subcategory': 'stem',
        'description': 'Master calculus, linear algebra, and advanced mathematical concepts with real-world applications',
        'difficulty': 'Advanced',
        'totalQuestions': 30,
        'timeLimit': 50,
        'rating': 4.8,
        'completions': 3240,
        'averageScore': 78.5,
        'createdBy': 'Dr. Sarah Mitchell',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'updatedAt': DateTime.now().subtract(const Duration(hours: 6)),
        'tags': ['calculus', 'linear-algebra', 'differential-equations', 'advanced', 'university-level'],
        'thumbnailColor': 'blue',
        'estimatedDuration': 50,
        'prerequisites': ['Algebra II', 'Pre-Calculus'],
        'learningOutcomes': ['Master derivative calculations', 'Understand integration techniques', 'Solve complex equations'],
        'category': QuizCategory.academic,
        'isNew': false,
        'isTrending': true,
        'isPremium': false,
      },
      {
        'id': 'featured_2',
        'title': 'Comprehensive Science Explorer',
        'subject': 'Science',
        'subcategory': 'stem',
        'description': 'Explore cutting-edge concepts in physics, chemistry, biology, and environmental science',
        'difficulty': 'Intermediate',
        'totalQuestions': 35,
        'timeLimit': 45,
        'rating': 4.7,
        'completions': 4180,
        'averageScore': 82.3,
        'createdBy': 'Prof. Johnson',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 1)),
        'tags': ['physics', 'chemistry', 'biology', 'environmental', 'research', 'laboratory'],
        'thumbnailColor': 'green',
        'estimatedDuration': 45,
        'prerequisites': ['High School Science'],
        'learningOutcomes': ['Understand scientific principles', 'Apply scientific method', 'Analyze experimental data'],
        'category': QuizCategory.academic,
        'isNew': false,
        'isTrending': true,
        'isPremium': false,
      },
      {
        'id': 'featured_3',
        'title': 'World History & Civilizations',
        'subject': 'History',
        'subcategory': 'humanities',
        'description': 'Journey through human civilization from ancient times to the modern era',
        'difficulty': 'Beginner',
        'totalQuestions': 40,
        'timeLimit': 40,
        'rating': 4.6,
        'completions': 5200,
        'averageScore': 85.7,
        'createdBy': 'Dr. Emily Davis',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        'updatedAt': DateTime.now().subtract(const Duration(hours: 12)),
        'tags': ['ancient-history', 'medieval', 'modern', 'civilizations', 'world-wars', 'cultural'],
        'thumbnailColor': 'orange',
        'estimatedDuration': 40,
        'prerequisites': [],
        'learningOutcomes': ['Understand historical timelines', 'Recognize cultural patterns', 'Connect past to present'],
        'category': QuizCategory.academic,
        'isNew': false,
        'isTrending': false,
        'isPremium': false,
      },
      {
        'id': 'featured_4',
        'title': 'Programming Fundamentals Pro',
        'subject': 'Computer Science',
        'subcategory': 'tech_certifications',
        'description': 'Master programming concepts across multiple languages and paradigms',
        'difficulty': 'Intermediate',
        'totalQuestions': 45,
        'timeLimit': 60,
        'rating': 4.9,
        'completions': 2850,
        'averageScore': 76.8,
        'createdBy': 'Tech Academy',
        'createdAt': DateTime.now().subtract(const Duration(hours: 18)),
        'updatedAt': DateTime.now().subtract(const Duration(hours: 2)),
        'tags': ['programming', 'algorithms', 'data-structures', 'coding', 'software-development'],
        'thumbnailColor': 'purple',
        'estimatedDuration': 60,
        'prerequisites': ['Basic Programming Knowledge'],
        'learningOutcomes': ['Write efficient code', 'Understand algorithms', 'Debug effectively'],
        'category': QuizCategory.certification,
        'isNew': true,
        'isTrending': true,
        'isPremium': true,
      },
      {
        'id': 'featured_5',
        'title': 'Business Strategy & Leadership',
        'subject': 'Business',
        'subcategory': 'business',
        'description': 'Develop strategic thinking and leadership skills for modern business challenges',
        'difficulty': 'Advanced',
        'totalQuestions': 25,
        'timeLimit': 35,
        'rating': 4.5,
        'completions': 1680,
        'averageScore': 73.2,
        'createdBy': 'MBA Institute',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 2)),
        'tags': ['strategy', 'leadership', 'management', 'business-analysis', 'decision-making'],
        'thumbnailColor': 'teal',
        'estimatedDuration': 35,
        'prerequisites': ['Business Fundamentals'],
        'learningOutcomes': ['Strategic planning', 'Team leadership', 'Business analysis'],
        'category': QuizCategory.professional,
        'isNew': false,
        'isTrending': false,
        'isPremium': true,
      },
    ];
  }

  // Get quick quiz options for different subjects
  static List<Map<String, dynamic>> getQuickQuizOptions() {
    return [
      {
        'subject': 'Mathematics',
        'title': 'Quick Math Challenge',
        'description': '10 questions to test your math skills',
        'questionCount': 10,
        'timeLimit': 15,
        'difficulty': 'Mixed',
      },
      {
        'subject': 'Science',
        'title': 'Science Snapshot',
        'description': 'Quick science knowledge check',
        'questionCount': 12,
        'timeLimit': 18,
        'difficulty': 'Mixed',
      },
      {
        'subject': 'History',
        'title': 'History Headlines',
        'description': 'Test your historical knowledge',
        'questionCount': 15,
        'timeLimit': 20,
        'difficulty': 'Mixed',
      },
      {
        'subject': 'Languages',
        'title': 'Language Lab',
        'description': 'Multi-language vocabulary test',
        'questionCount': 20,
        'timeLimit': 25,
        'difficulty': 'Mixed',
      },
    ];
  }

  // Get recent quiz attempts (mock data)
  static List<Map<String, dynamic>> getRecentQuizAttempts() {
    return [
      {
        'quizTitle': 'Mathematics Mastery Challenge',
        'subject': 'Mathematics',
        'score': 18,
        'totalQuestions': 25,
        'accuracy': 72.0,
        'timeSpent': 2580, // in seconds
        'completedAt': DateTime.now().subtract(const Duration(hours: 2)),
        'difficulty': 'Advanced',
      },
      {
        'quizTitle': 'Science Explorer Quiz',
        'subject': 'Science',
        'score': 26,
        'totalQuestions': 30,
        'accuracy': 86.7,
        'timeSpent': 1920,
        'completedAt': DateTime.now().subtract(const Duration(days: 1)),
        'difficulty': 'Intermediate',
      },
      {
        'quizTitle': 'Quick Math Challenge',
        'subject': 'Mathematics',
        'score': 8,
        'totalQuestions': 10,
        'accuracy': 80.0,
        'timeSpent': 720,
        'completedAt': DateTime.now().subtract(const Duration(days: 2)),
        'difficulty': 'Mixed',
      },
    ];
  }

  static List<Map<String, dynamic>> getQuizQuestions(String subject, int totalQuestions) {
    final Map<String, List<Map<String, dynamic>>> questionBank = {
      'Mathematics': [
        {
          'id': 'math_1',
          'question': 'What is the derivative of x² + 3x + 2?',
          'options': ['2x + 3', 'x² + 3', '2x + 2', '3x + 2'],
          'correctAnswer': 0,
          'explanation': 'The derivative of x² is 2x, derivative of 3x is 3, and derivative of constant 2 is 0. So the answer is 2x + 3.',
        },
        {
          'id': 'math_2',
          'question': 'Solve for x: 2x + 5 = 13',
          'options': ['x = 4', 'x = 6', 'x = 8', 'x = 9'],
          'correctAnswer': 0,
          'explanation': '2x + 5 = 13, so 2x = 8, therefore x = 4.',
        },
        {
          'id': 'math_3',
          'question': 'What is the area of a circle with radius 5?',
          'options': ['25π', '10π', '50π', '15π'],
          'correctAnswer': 0,
          'explanation': 'Area = πr², so with r = 5, Area = π(5)² = 25π.',
        },
        {
          'id': 'math_4',
          'question': 'What is the integral of 2x dx?',
          'options': ['x² + C', '2x² + C', 'x²/2 + C', '2x + C'],
          'correctAnswer': 0,
          'explanation': 'The integral of 2x is x² + C.',
        },
        {
          'id': 'math_5',
          'question': 'If log₂(8) = x, what is x?',
          'options': ['3', '4', '2', '8'],
          'correctAnswer': 0,
          'explanation': '2³ = 8, so log₂(8) = 3.',
        },
        {
          'id': 'math_6',
          'question': 'What is the value of sin(π/2)?',
          'options': ['1', '0', '√2/2', '√3/2'],
          'correctAnswer': 0,
          'explanation': 'sin(π/2) = sin(90°) = 1.',
        },
      ],
      'Science': [
        {
          'id': 'science_1',
          'question': 'What is the chemical symbol for gold?',
          'options': ['Go', 'Gd', 'Au', 'Ag'],
          'correctAnswer': 2,
          'explanation': 'Au comes from the Latin word "aurum" meaning gold.',
        },
        {
          'id': 'science_2',
          'question': 'What is the speed of light in vacuum?',
          'options': ['3 × 10⁸ m/s', '3 × 10⁶ m/s', '3 × 10¹⁰ m/s', '3 × 10⁹ m/s'],
          'correctAnswer': 0,
          'explanation': 'The speed of light in vacuum is approximately 3 × 10⁸ meters per second.',
        },
        {
          'id': 'science_3',
          'question': 'Which planet is closest to the Sun?',
          'options': ['Venus', 'Mercury', 'Earth', 'Mars'],
          'correctAnswer': 1,
          'explanation': 'Mercury is the planet closest to the Sun in our solar system.',
        },
        {
          'id': 'science_4',
          'question': 'What is the molecular formula for water?',
          'options': ['H₂O', 'CO₂', 'NaCl', 'CH₄'],
          'correctAnswer': 0,
          'explanation': 'Water consists of two hydrogen atoms and one oxygen atom, making it H₂O.',
        },
        {
          'id': 'science_5',
          'question': 'What force keeps planets in orbit around the Sun?',
          'options': ['Electromagnetic force', 'Strong force', 'Gravity', 'Weak force'],
          'correctAnswer': 2,
          'explanation': 'Gravity is the fundamental force that keeps planets in orbit around the Sun.',
        },
        {
          'id': 'science_6',
          'question': 'What is the pH of pure water?',
          'options': ['7', '0', '14', '1'],
          'correctAnswer': 0,
          'explanation': 'Pure water has a pH of 7, which is neutral on the pH scale.',
        },
      ],
      'History': [
        {
          'id': 'history_1',
          'question': 'In which year did World War II end?',
          'options': ['1944', '1945', '1946', '1947'],
          'correctAnswer': 1,
          'explanation': 'World War II ended in 1945 with the surrender of Japan in September.',
        },
        {
          'id': 'history_2',
          'question': 'Who was the first President of the United States?',
          'options': ['Thomas Jefferson', 'George Washington', 'John Adams', 'Benjamin Franklin'],
          'correctAnswer': 1,
          'explanation': 'George Washington was the first President of the United States, serving from 1789 to 1797.',
        },
        {
          'id': 'history_3',
          'question': 'Which ancient wonder was located in Alexandria?',
          'options': ['Colossus of Rhodes', 'Lighthouse of Alexandria', 'Hanging Gardens', 'Great Pyramid'],
          'correctAnswer': 1,
          'explanation': 'The Lighthouse of Alexandria (Pharos of Alexandria) was one of the Seven Wonders of the Ancient World.',
        },
        {
          'id': 'history_4',
          'question': 'The Renaissance period began in which country?',
          'options': ['France', 'England', 'Italy', 'Germany'],
          'correctAnswer': 2,
          'explanation': 'The Renaissance began in Italy during the 14th century.',
        },
        {
          'id': 'history_5',
          'question': 'Who wrote "The Communist Manifesto"?',
          'options': ['Lenin', 'Marx and Engels', 'Stalin', 'Trotsky'],
          'correctAnswer': 1,
          'explanation': 'Karl Marx and Friedrich Engels co-authored "The Communist Manifesto" in 1848.',
        },
        {
          'id': 'history_6',
          'question': 'The Berlin Wall fell in which year?',
          'options': ['1987', '1989', '1991', '1985'],
          'correctAnswer': 1,
          'explanation': 'The Berlin Wall fell on November 9, 1989, marking the end of the Cold War era in Germany.',
        },
      ],
      'Languages': [
        {
          'id': 'languages_1',
          'question': 'What does "Hola" mean in English?',
          'options': ['Goodbye', 'Hello', 'Thank you', 'Please'],
          'correctAnswer': 1,
          'explanation': '"Hola" is a Spanish greeting that means "Hello" in English.',
        },
        {
          'id': 'languages_2',
          'question': 'Which language has the most native speakers worldwide?',
          'options': ['English', 'Spanish', 'Mandarin Chinese', 'Hindi'],
          'correctAnswer': 2,
          'explanation': 'Mandarin Chinese has the most native speakers worldwide, with over 900 million speakers.',
        },
        {
          'id': 'languages_3',
          'question': 'What does "Bonjour" mean?',
          'options': ['Good evening', 'Good morning', 'Goodbye', 'Thank you'],
          'correctAnswer': 1,
          'explanation': '"Bonjour" is French for "Good morning" or "Hello" during daytime.',
        },
        {
          'id': 'languages_4',
          'question': 'Which alphabet does Russian use?',
          'options': ['Latin', 'Cyrillic', 'Greek', 'Arabic'],
          'correctAnswer': 1,
          'explanation': 'Russian uses the Cyrillic alphabet, which has 33 letters.',
        },
        {
          'id': 'languages_5',
          'question': 'What is "Danke" in English?',
          'options': ['Please', 'Sorry', 'Thank you', 'Excuse me'],
          'correctAnswer': 2,
          'explanation': '"Danke" is German for "Thank you".',
        },
        {
          'id': 'languages_6',
          'question': 'Which language is spoken in Brazil?',
          'options': ['Spanish', 'Portuguese', 'Italian', 'French'],
          'correctAnswer': 1,
          'explanation': 'Portuguese is the official language of Brazil.',
        },
      ],
      'Technology': [
        {
          'id': 'tech_1',
          'question': 'What does CPU stand for?',
          'options': ['Computer Personal Unit', 'Central Processing Unit', 'Central Program Unit', 'Computer Processing Unit'],
          'correctAnswer': 1,
          'explanation': 'CPU stands for Central Processing Unit, the main processor of a computer.',
          'difficulty': 'Easy',
          'tags': ['hardware', 'basics'],
        },
        {
          'id': 'tech_2',
          'question': 'Which company created the iPhone?',
          'options': ['Google', 'Microsoft', 'Apple', 'Samsung'],
          'correctAnswer': 2,
          'explanation': 'Apple Inc. created and released the first iPhone in 2007.',
          'difficulty': 'Easy',
          'tags': ['mobile', 'history'],
        },
        {
          'id': 'tech_3',
          'question': 'What does HTML stand for?',
          'options': ['Hyper Text Markup Language', 'High Tech Modern Language', 'Home Tool Markup Language', 'Hyper Transfer Markup Language'],
          'correctAnswer': 0,
          'explanation': 'HTML stands for HyperText Markup Language, used to create web pages.',
          'difficulty': 'Easy',
          'tags': ['web-development', 'programming'],
        },
        {
          'id': 'tech_4',
          'question': 'Which programming language is known for artificial intelligence?',
          'options': ['Java', 'Python', 'C++', 'JavaScript'],
          'correctAnswer': 1,
          'explanation': 'Python is widely used in artificial intelligence and machine learning applications.',
          'difficulty': 'Intermediate',
          'tags': ['programming', 'ai', 'machine-learning'],
        },
        {
          'id': 'tech_5',
          'question': 'What does "www" stand for?',
          'options': ['World Wide Web', 'World Wide Website', 'Web World Wide', 'World Web Wide'],
          'correctAnswer': 0,
          'explanation': 'WWW stands for World Wide Web, the information system on the Internet.',
          'difficulty': 'Easy',
          'tags': ['internet', 'basics'],
        },
        {
          'id': 'tech_6',
          'question': 'Which data structure uses LIFO (Last In, First Out)?',
          'options': ['Queue', 'Stack', 'Array', 'Linked List'],
          'correctAnswer': 1,
          'explanation': 'A Stack follows the LIFO principle - the last element added is the first one removed.',
          'difficulty': 'Intermediate',
          'tags': ['data-structures', 'algorithms'],
        },
        {
          'id': 'tech_7',
          'question': 'What is the time complexity of binary search?',
          'options': ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
          'correctAnswer': 1,
          'explanation': 'Binary search has O(log n) time complexity because it halves the search space at each step.',
          'difficulty': 'Advanced',
          'tags': ['algorithms', 'complexity'],
        },
        {
          'id': 'tech_8',
          'question': 'Which protocol is used for secure web browsing?',
          'options': ['HTTP', 'HTTPS', 'FTP', 'SMTP'],
          'correctAnswer': 1,
          'explanation': 'HTTPS (HTTP Secure) uses SSL/TLS encryption for secure web communication.',
          'difficulty': 'Intermediate',
          'tags': ['security', 'networking'],
        },
      ],
      'Computer Science': [
        {
          'id': 'cs_1',
          'question': 'What is polymorphism in object-oriented programming?',
          'options': ['Having multiple constructors', 'One interface, multiple implementations', 'Creating multiple objects', 'Using multiple inheritance'],
          'correctAnswer': 1,
          'explanation': 'Polymorphism allows objects of different types to be treated as objects of a common base type.',
          'difficulty': 'Intermediate',
          'tags': ['oop', 'programming-concepts'],
        },
        {
          'id': 'cs_2',
          'question': 'Which sorting algorithm has the best average-case time complexity?',
          'options': ['Bubble Sort', 'Quick Sort', 'Selection Sort', 'Insertion Sort'],
          'correctAnswer': 1,
          'explanation': 'Quick Sort has an average time complexity of O(n log n), which is optimal for comparison-based sorting.',
          'difficulty': 'Advanced',
          'tags': ['algorithms', 'sorting'],
        },
        {
          'id': 'cs_3',
          'question': 'What does SQL stand for?',
          'options': ['Structured Query Language', 'Simple Query Language', 'Sequential Query Language', 'Standard Query Language'],
          'correctAnswer': 0,
          'explanation': 'SQL stands for Structured Query Language, used for managing relational databases.',
          'difficulty': 'Easy',
          'tags': ['database', 'sql'],
        },
        {
          'id': 'cs_4',
          'question': 'Which design pattern ensures only one instance of a class exists?',
          'options': ['Factory', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 2,
          'explanation': 'The Singleton pattern ensures a class has only one instance and provides global access to it.',
          'difficulty': 'Intermediate',
          'tags': ['design-patterns', 'software-engineering'],
        },
      ],
      'Geography': [
        {
          'id': 'geo_1',
          'question': 'What is the capital of Australia?',
          'options': ['Sydney', 'Melbourne', 'Canberra', 'Brisbane'],
          'correctAnswer': 2,
          'explanation': 'Canberra is the capital city of Australia, located in the Australian Capital Territory.',
          'difficulty': 'Easy',
          'tags': ['capitals', 'oceania'],
        },
        {
          'id': 'geo_2',
          'question': 'Which is the longest river in the world?',
          'options': ['Amazon', 'Nile', 'Mississippi', 'Yangtze'],
          'correctAnswer': 1,
          'explanation': 'The Nile River in Africa is traditionally considered the longest river in the world at about 6,650 km.',
          'difficulty': 'Easy',
          'tags': ['rivers', 'physical-geography'],
        },
        {
          'id': 'geo_3',
          'question': 'Which country has the most time zones?',
          'options': ['USA', 'Russia', 'China', 'Canada'],
          'correctAnswer': 1,
          'explanation': 'Russia spans 11 time zones, more than any other country in the world.',
          'difficulty': 'Intermediate',
          'tags': ['time-zones', 'countries'],
        },
        {
          'id': 'geo_4',
          'question': 'What is the smallest country in the world?',
          'options': ['Monaco', 'Vatican City', 'San Marino', 'Liechtenstein'],
          'correctAnswer': 1,
          'explanation': 'Vatican City is the smallest country in the world, with an area of just 0.17 square miles.',
          'difficulty': 'Easy',
          'tags': ['countries', 'size'],
        },
      ],
      'Art': [
        {
          'id': 'art_1',
          'question': 'Who painted the Mona Lisa?',
          'options': ['Michelangelo', 'Leonardo da Vinci', 'Raphael', 'Donatello'],
          'correctAnswer': 1,
          'explanation': 'Leonardo da Vinci painted the Mona Lisa between 1503 and 1519.',
          'difficulty': 'Easy',
          'tags': ['renaissance', 'painting'],
        },
        {
          'id': 'art_2',
          'question': 'Which art movement is Pablo Picasso most associated with?',
          'options': ['Impressionism', 'Cubism', 'Surrealism', 'Abstract Expressionism'],
          'correctAnswer': 1,
          'explanation': 'Pablo Picasso co-founded the Cubist movement in the early 20th century.',
          'difficulty': 'Intermediate',
          'tags': ['cubism', 'modern-art'],
        },
        {
          'id': 'art_3',
          'question': 'What is the primary color that cannot be created by mixing other colors?',
          'options': ['Green', 'Orange', 'Red', 'Purple'],
          'correctAnswer': 2,
          'explanation': 'Red is one of the three primary colors (red, blue, yellow) that cannot be created by mixing other colors.',
          'difficulty': 'Easy',
          'tags': ['color-theory', 'basics'],
        },
        {
          'id': 'art_4',
          'question': 'Which museum houses the Starry Night painting?',
          'options': ['Louvre', 'Museum of Modern Art', 'Metropolitan Museum', 'Tate Modern'],
          'correctAnswer': 1,
          'explanation': 'Van Gogh\'s "The Starry Night" is housed in the Museum of Modern Art (MoMA) in New York.',
          'difficulty': 'Intermediate',
          'tags': ['museums', 'famous-paintings'],
        },
      ],
      'Economics': [
        {
          'id': 'econ_1',
          'question': 'What does GDP stand for?',
          'options': ['Gross Domestic Product', 'General Domestic Product', 'Global Domestic Product', 'Gross Development Product'],
          'correctAnswer': 0,
          'explanation': 'GDP stands for Gross Domestic Product, measuring the total economic output of a country.',
          'difficulty': 'Easy',
          'tags': ['macroeconomics', 'indicators'],
        },
        {
          'id': 'econ_2',
          'question': 'What happens to demand when the price of a good increases?',
          'options': ['Demand increases', 'Demand decreases', 'Demand stays the same', 'Demand becomes zero'],
          'correctAnswer': 1,
          'explanation': 'According to the law of demand, as price increases, quantity demanded typically decreases.',
          'difficulty': 'Easy',
          'tags': ['microeconomics', 'demand'],
        },
        {
          'id': 'econ_3',
          'question': 'What is inflation?',
          'options': ['Decrease in prices', 'Increase in prices', 'Stable prices', 'Currency devaluation'],
          'correctAnswer': 1,
          'explanation': 'Inflation is the general increase in prices of goods and services over time.',
          'difficulty': 'Easy',
          'tags': ['macroeconomics', 'inflation'],
        },
      ],
      'Psychology': [
        {
          'id': 'psych_1',
          'question': 'Who is considered the father of psychoanalysis?',
          'options': ['Carl Jung', 'Sigmund Freud', 'B.F. Skinner', 'Ivan Pavlov'],
          'correctAnswer': 1,
          'explanation': 'Sigmund Freud developed psychoanalysis and is considered its founder.',
          'difficulty': 'Easy',
          'tags': ['psychoanalysis', 'history'],
        },
        {
          'id': 'psych_2',
          'question': 'What is classical conditioning?',
          'options': ['Learning through rewards', 'Learning through association', 'Learning through observation', 'Learning through punishment'],
          'correctAnswer': 1,
          'explanation': 'Classical conditioning is learning through association between a neutral stimulus and a natural response.',
          'difficulty': 'Intermediate',
          'tags': ['conditioning', 'learning'],
        },
        {
          'id': 'psych_3',
          'question': 'What does IQ measure?',
          'options': ['Emotional intelligence', 'Intelligence quotient', 'Social skills', 'Memory capacity'],
          'correctAnswer': 1,
          'explanation': 'IQ stands for Intelligence Quotient, measuring cognitive abilities and problem-solving skills.',
          'difficulty': 'Easy',
          'tags': ['intelligence', 'testing'],
        },
      ],
      'Literature': [
        {
          'id': 'lit_1',
          'question': 'Who wrote "Pride and Prejudice"?',
          'options': ['Charlotte Brontë', 'Emily Dickinson', 'Jane Austen', 'Virginia Woolf'],
          'correctAnswer': 2,
          'explanation': 'Jane Austen wrote "Pride and Prejudice", published in 1813.',
        },
        {
          'id': 'lit_2',
          'question': 'Which play features the characters Romeo and Juliet?',
          'options': ['Hamlet', 'Macbeth', 'Romeo and Juliet', 'Othello'],
          'correctAnswer': 2,
          'explanation': 'Romeo and Juliet are the main characters in Shakespeare\'s tragedy of the same name.',
        },
        {
          'id': 'lit_3',
          'question': 'Who wrote "1984"?',
          'options': ['George Orwell', 'Aldous Huxley', 'Ray Bradbury', 'H.G. Wells'],
          'correctAnswer': 0,
          'explanation': 'George Orwell wrote "1984", a dystopian novel published in 1949.',
        },
        {
          'id': 'lit_4',
          'question': 'Which epic poem tells the story of Odysseus?',
          'options': ['The Iliad', 'The Odyssey', 'The Aeneid', 'Beowulf'],
          'correctAnswer': 1,
          'explanation': 'The Odyssey is Homer\'s epic poem about Odysseus\'s journey home after the Trojan War.',
        },
        {
          'id': 'lit_5',
          'question': 'Who wrote "To Kill a Mockingbird"?',
          'options': ['Harper Lee', 'Maya Angelou', 'Toni Morrison', 'Flannery O\'Connor'],
          'correctAnswer': 0,
          'explanation': 'Harper Lee wrote "To Kill a Mockingbird", published in 1960.',
        },
        {
          'id': 'lit_6',
          'question': 'Which novel begins with "It was the best of times, it was the worst of times"?',
          'options': ['Great Expectations', 'A Tale of Two Cities', 'Oliver Twist', 'David Copperfield'],
          'correctAnswer': 1,
          'explanation': 'This famous opening line is from Charles Dickens\' "A Tale of Two Cities".',
        },
      ],
    };

    final subjectQuestions = questionBank[subject] ?? questionBank['Science']!;
    
    // Shuffle questions and take the required number
    final shuffledQuestions = List<Map<String, dynamic>>.from(subjectQuestions)..shuffle();
    
    // If we need more questions than available, cycle through them
    final List<Map<String, dynamic>> selectedQuestions = [];
    for (int i = 0; i < totalQuestions; i++) {
      selectedQuestions.add(shuffledQuestions[i % shuffledQuestions.length]);
    }
    
    return selectedQuestions;
  }

  static Map<String, dynamic> createMockQuiz(String subject, String difficulty, int totalQuestions, int timeLimit) {
    return {
      'id': 'quiz_${DateTime.now().millisecondsSinceEpoch}',
      'title': '$subject $difficulty Quiz',
      'subject': subject,
      'description': 'Test your knowledge of $subject concepts',
      'difficulty': difficulty,
      'totalQuestions': totalQuestions,
      'timeLimit': timeLimit,
      'questions': getQuizQuestions(subject, totalQuestions),
      'isPublic': true,
      'createdAt': DateTime.now(),
      'createdBy': 'System',
    };
  }

  // MARK: - Analytics and Statistics
  static QuizAnalytics getQuizAnalytics() {
    return const QuizAnalytics(
      totalAttempts: 15640,
      averageScore: 78.2,
      averageTime: 1850.5,
      difficultyDistribution: {
        'Beginner': 4200,
        'Intermediate': 7800,
        'Advanced': 3640,
      },
      popularTags: [
        'programming',
        'science',
        'mathematics',
        'history',
        'languages'
      ],
      userSatisfactionRating: 4.6,
    );
  }

  static List<Map<String, dynamic>> getTrendingQuizzes() {
    return [
      {
        'id': 'trending_1',
        'title': 'AI & Machine Learning Essentials',
        'subject': 'Computer Science',
        'difficulty': 'Intermediate',
        'totalQuestions': 20,
        'timeLimit': 30,
        'rating': 4.9,
        'completions': 1850,
        'trend': 'up',
        'trendPercentage': 35.2,
        'tags': ['ai', 'machine-learning', 'python'],
      },
      {
        'id': 'trending_2',
        'title': 'Climate Change & Environmental Science',
        'subject': 'Science',
        'difficulty': 'Beginner',
        'totalQuestions': 25,
        'timeLimit': 25,
        'rating': 4.7,
        'completions': 2340,
        'trend': 'up',
        'trendPercentage': 42.8,
        'tags': ['environment', 'climate', 'sustainability'],
      },
      {
        'id': 'trending_3',
        'title': 'Cryptocurrency & Blockchain',
        'subject': 'Technology',
        'difficulty': 'Intermediate',
        'totalQuestions': 18,
        'timeLimit': 25,
        'rating': 4.5,
        'completions': 1460,
        'trend': 'up',
        'trendPercentage': 28.6,
        'tags': ['blockchain', 'cryptocurrency', 'fintech'],
      },
    ];
  }

  static List<Map<String, dynamic>> getPopularQuizzes() {
    return [
      {
        'id': 'popular_1',
        'title': 'World Geography Master Class',
        'subject': 'Geography',
        'difficulty': 'Intermediate',
        'totalQuestions': 50,
        'timeLimit': 45,
        'rating': 4.8,
        'completions': 8920,
        'averageScore': 84.2,
      },
      {
        'id': 'popular_2',
        'title': 'Art History Through the Ages',
        'subject': 'Art',
        'difficulty': 'Beginner',
        'totalQuestions': 35,
        'timeLimit': 40,
        'rating': 4.6,
        'completions': 6730,
        'averageScore': 79.1,
      },
    ];
  }

  // MARK: - Recommendations
  static List<Map<String, dynamic>> getRecommendedQuizzes({
    List<String> userInterests = const [],
    String? lastSubject,
    String? preferredDifficulty,
  }) {
    final recommendations = <Map<String, dynamic>>[];
    
    // Add trending quizzes if user has related interests
    if (userInterests.contains('technology') || userInterests.contains('programming')) {
      recommendations.add({
        'id': 'rec_tech_1',
        'title': 'Advanced Programming Patterns',
        'subject': 'Computer Science',
        'difficulty': 'Advanced',
        'totalQuestions': 30,
        'timeLimit': 45,
        'rating': 4.8,
        'recommendationReason': 'Based on your interest in programming',
        'tags': ['design-patterns', 'software-architecture'],
      });
    }
    
    // Add subject-related recommendations
    if (lastSubject == 'Mathematics') {
      recommendations.add({
        'id': 'rec_math_1',
        'title': 'Statistics and Probability',
        'subject': 'Mathematics',
        'difficulty': preferredDifficulty ?? 'Intermediate',
        'totalQuestions': 25,
        'timeLimit': 35,
        'rating': 4.7,
        'recommendationReason': 'Continue your mathematics journey',
        'tags': ['statistics', 'probability', 'data-analysis'],
      });
    }
    
    // Default recommendations if no specific interests
    if (recommendations.isEmpty) {
      recommendations.addAll([
        {
          'id': 'rec_general_1',
          'title': 'General Knowledge Champion',
          'subject': 'General Knowledge',
          'difficulty': 'Mixed',
          'totalQuestions': 40,
          'timeLimit': 30,
          'rating': 4.5,
          'recommendationReason': 'Popular with users like you',
          'tags': ['trivia', 'general', 'mixed'],
        },
        {
          'id': 'rec_general_2',
          'title': 'Current Events & News',
          'subject': 'General Knowledge',
          'difficulty': 'Beginner',
          'totalQuestions': 20,
          'timeLimit': 25,
          'rating': 4.3,
          'recommendationReason': 'Stay informed with current affairs',
          'tags': ['current-events', 'news', 'world'],
        },
      ]);
    }
    
    return recommendations;
  }

  // MARK: - Quiz Collections and Playlists
  static List<Map<String, dynamic>> getQuizCollections() {
    return [
      {
        'id': 'collection_1',
        'title': 'STEM Excellence Path',
        'description': 'Master Science, Technology, Engineering, and Mathematics',
        'category': QuizCategory.academic,
        'quizCount': 12,
        'totalQuestions': 340,
        'estimatedTime': 280, // minutes
        'difficulty': 'Progressive', // Starts easy, gets harder
        'subjects': ['Mathematics', 'Science', 'Computer Science', 'Technology'],
        'thumbnailColor': 'blue',
        'rating': 4.8,
        'enrollments': 2540,
        'quizzes': [
          'featured_1', 'featured_2', 'featured_4', // reference to quiz IDs
        ],
      },
      {
        'id': 'collection_2',
        'title': 'Business Professional Certification',
        'description': 'Comprehensive business knowledge for professionals',
        'category': QuizCategory.professional,
        'quizCount': 8,
        'totalQuestions': 200,
        'estimatedTime': 160,
        'difficulty': 'Advanced',
        'subjects': ['Business', 'Economics', 'Management'],
        'thumbnailColor': 'teal',
        'rating': 4.6,
        'enrollments': 1340,
        'quizzes': [
          'featured_5',
        ],
      },
      {
        'id': 'collection_3',
        'title': 'World Culture Explorer',
        'description': 'Journey through world history, art, and languages',
        'category': QuizCategory.fun,
        'quizCount': 10,
        'totalQuestions': 280,
        'estimatedTime': 200,
        'difficulty': 'Mixed',
        'subjects': ['History', 'Art', 'Geography', 'Languages'],
        'thumbnailColor': 'orange',
        'rating': 4.7,
        'enrollments': 3890,
        'quizzes': [
          'featured_3',
        ],
      },
    ];
  }

  // MARK: - Search and Filtering
  static List<Map<String, dynamic>> searchQuizzes({
    String query = '',
    List<String> subjects = const [],
    List<String> difficulties = const [],
    int? maxQuestions,
    int? maxTimeLimit,
    List<String> tags = const [],
    QuizCategory? category,
  }) {
    var allQuizzes = getFeaturedQuizzes();
    allQuizzes.addAll(getTrendingQuizzes());
    allQuizzes.addAll(getPopularQuizzes());
    
    if (query.isNotEmpty) {
      allQuizzes = allQuizzes.where((quiz) {
        return quiz['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
               quiz['description'].toString().toLowerCase().contains(query.toLowerCase()) ||
               quiz['subject'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    
    if (subjects.isNotEmpty) {
      allQuizzes = allQuizzes.where((quiz) => subjects.contains(quiz['subject'])).toList();
    }
    
    if (difficulties.isNotEmpty) {
      allQuizzes = allQuizzes.where((quiz) => difficulties.contains(quiz['difficulty'])).toList();
    }
    
    if (maxQuestions != null) {
      allQuizzes = allQuizzes.where((quiz) => quiz['totalQuestions'] <= maxQuestions).toList();
    }
    
    if (maxTimeLimit != null) {
      allQuizzes = allQuizzes.where((quiz) => quiz['timeLimit'] <= maxTimeLimit).toList();
    }
    
    if (tags.isNotEmpty) {
      allQuizzes = allQuizzes.where((quiz) {
        final quizTags = List<String>.from(quiz['tags'] ?? []);
        return tags.any((tag) => quizTags.contains(tag));
      }).toList();
    }
    
    return allQuizzes;
  }

  static List<String> getAvailableSubjects() {
    return [
      'Mathematics',
      'Science',
      'History',
      'Languages',
      'Technology',
      'Computer Science',
      'Geography',
      'Art',
      'Economics',
      'Psychology',
      'Literature',
      'Business',
      'General Knowledge',
    ];
  }

  static List<String> getAvailableDifficulties() {
    return ['Beginner', 'Intermediate', 'Advanced', 'Mixed'];
  }

  static List<String> getPopularTags() {
    return [
      'programming',
      'science',
      'mathematics',
      'history',
      'languages',
      'technology',
      'business',
      'art',
      'geography',
      'literature',
      'ai',
      'machine-learning',
      'algorithms',
      'web-development',
      'mobile',
      'data-structures',
      'design-patterns',
      'database',
      'networking',
      'security',
    ];
  }

  // MARK: - User Performance Analytics
  static Map<String, dynamic> getUserPerformanceAnalytics() {
    return {
      'totalQuizzesCompleted': 47,
      'averageScore': 82.4,
      'totalTimeSpent': 48600, // seconds
      'streakDays': 12,
      'favoriteSubject': 'Computer Science',
      'strongestSkills': ['Programming', 'Logic', 'Problem Solving'],
      'improvementAreas': ['Art History', 'Geography'],
      'monthlyProgress': {
        'January': {'completed': 8, 'averageScore': 78.5},
        'February': {'completed': 12, 'averageScore': 81.2},
        'March': {'completed': 15, 'averageScore': 85.1},
        'April': {'completed': 12, 'averageScore': 83.7},
      },
      'achievements': [
        {
          'id': 'first_quiz',
          'title': 'Getting Started',
          'description': 'Complete your first quiz',
          'earned': true,
          'earnedAt': DateTime.now().subtract(const Duration(days: 30)),
        },
        {
          'id': 'streak_7',
          'title': 'Week Warrior',
          'description': 'Complete quizzes for 7 consecutive days',
          'earned': true,
          'earnedAt': DateTime.now().subtract(const Duration(days: 5)),
        },
        {
          'id': 'perfect_score',
          'title': 'Perfect Score',
          'description': 'Get 100% on any quiz',
          'earned': false,
        },
      ],
    };
  }

  // MARK: - Enhanced Quick Quiz Options
  static List<Map<String, dynamic>> getEnhancedQuickQuizOptions() {
    return [
      {
        'id': 'quick_math',
        'subject': 'Mathematics',
        'title': 'Quick Math Challenge',
        'description': 'Test your mathematical skills in just 10 minutes',
        'questionCount': 10,
        'timeLimit': 15,
        'difficulty': 'Mixed',
        'icon': 'calculate',
        'color': 'blue',
        'estimatedTime': 10,
        'tags': ['algebra', 'arithmetic', 'quick'],
      },
      {
        'id': 'quick_science',
        'subject': 'Science',
        'title': 'Science Flash',
        'description': 'Quick dive into scientific concepts',
        'questionCount': 12,
        'timeLimit': 18,
        'difficulty': 'Mixed',
        'icon': 'science',
        'color': 'green',
        'estimatedTime': 12,
        'tags': ['physics', 'chemistry', 'biology'],
      },
      {
        'id': 'quick_tech',
        'subject': 'Technology',
        'title': 'Tech Bytes',
        'description': 'Byte-sized technology knowledge test',
        'questionCount': 8,
        'timeLimit': 12,
        'difficulty': 'Mixed',
        'icon': 'computer',
        'color': 'purple',
        'estimatedTime': 8,
        'tags': ['programming', 'hardware', 'internet'],
      },
      {
        'id': 'quick_general',
        'subject': 'General Knowledge',
        'title': 'Brain Teaser',
        'description': 'Mixed topics to challenge your knowledge',
        'questionCount': 15,
        'timeLimit': 20,
        'difficulty': 'Mixed',
        'icon': 'psychology',
        'color': 'orange',
        'estimatedTime': 15,
        'tags': ['trivia', 'general', 'mixed'],
      },
    ];
  }

  // Getter methods for categories and subcategories
  static List<QuizSubcategory> get subcategories => _subcategories;
  
  static List<QuizSubcategory> getSubcategoriesByCategory(QuizCategory category) {
    return _subcategories.where((sub) => sub.category == category).toList();
  }
}
