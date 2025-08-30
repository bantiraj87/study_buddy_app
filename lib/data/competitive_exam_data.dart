import 'package:flutter/material.dart';

enum CompetitiveExamType {
  ssc,
  banking,
  railway,
  police,
  defence,
  upsc,
  state_pcs,
  teaching,
  insurance,
  other,
}

enum TestType {
  mockTest,
  sectionTest,
  fullTest,
  practiceSet,
  previousYear,
  chapterWise,
}

class CompetitiveExamCategory {
  final String id;
  final String name;
  final String shortName;
  final String description;
  final CompetitiveExamType type;
  final IconData icon;
  final Color color;
  final List<CompetitiveSubject> subjects;
  final Map<String, dynamic> examPattern;
  final List<String> eligibilityCriteria;
  final String applicationProcess;
  final List<ExamSchedule> upcomingExams;

  const CompetitiveExamCategory({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.type,
    required this.icon,
    required this.color,
    required this.subjects,
    required this.examPattern,
    required this.eligibilityCriteria,
    required this.applicationProcess,
    required this.upcomingExams,
  });
}

class CompetitiveSubject {
  final String id;
  final String name;
  final String shortName;
  final String description;
  final IconData icon;
  final Color color;
  final int totalMarks;
  final int totalQuestions;
  final int timeLimit; // in minutes
  final bool hasNegativeMarking;
  final double negativeMarkingRatio;
  final List<String> topics;
  final String difficultyLevel;
  final List<String> syllabus;

  const CompetitiveSubject({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.icon,
    required this.color,
    required this.totalMarks,
    required this.totalQuestions,
    required this.timeLimit,
    required this.hasNegativeMarking,
    required this.negativeMarkingRatio,
    required this.topics,
    required this.difficultyLevel,
    required this.syllabus,
  });
}

class ExamSchedule {
  final String examName;
  final String examCode;
  final DateTime applicationStart;
  final DateTime applicationEnd;
  final DateTime examDate;
  final DateTime resultDate;
  final String status; // upcoming, ongoing, completed
  final String officialWebsite;
  final List<String> importantDates;
  final Map<String, dynamic> examFees;
  final String notification;

  const ExamSchedule({
    required this.examName,
    required this.examCode,
    required this.applicationStart,
    required this.applicationEnd,
    required this.examDate,
    required this.resultDate,
    required this.status,
    required this.officialWebsite,
    required this.importantDates,
    required this.examFees,
    required this.notification,
  });
}

class MockTestSeries {
  final String id;
  final String title;
  final String description;
  final CompetitiveExamType examType;
  final String examSubType; // like SSC CGL, SSC CHSL, etc.
  final TestType testType;
  final List<TestSection> sections;
  final int totalQuestions;
  final int totalMarks;
  final int timeLimit; // in minutes
  final bool hasNegativeMarking;
  final double negativeMarkingRatio;
  final String difficultyLevel;
  final DateTime createdAt;
  final DateTime validUntil;
  final int attempts;
  final double averageScore;
  final int totalAttempts;
  final bool isPremium;
  final String language; // Hindi, English, Bilingual

  const MockTestSeries({
    required this.id,
    required this.title,
    required this.description,
    required this.examType,
    required this.examSubType,
    required this.testType,
    required this.sections,
    required this.totalQuestions,
    required this.totalMarks,
    required this.timeLimit,
    required this.hasNegativeMarking,
    required this.negativeMarkingRatio,
    required this.difficultyLevel,
    required this.createdAt,
    required this.validUntil,
    required this.attempts,
    required this.averageScore,
    required this.totalAttempts,
    required this.isPremium,
    required this.language,
  });
}

class TestSection {
  final String id;
  final String name;
  final String subjectId;
  final int totalQuestions;
  final int totalMarks;
  final int timeLimit; // in minutes
  final bool hasNegativeMarking;
  final double negativeMarkingRatio;
  final double sectionalCutoff;
  final List<String> topicsCovered;
  final List<QuestionData> questions;

  const TestSection({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.totalQuestions,
    required this.totalMarks,
    required this.timeLimit,
    required this.hasNegativeMarking,
    required this.negativeMarkingRatio,
    required this.sectionalCutoff,
    required this.topicsCovered,
    required this.questions,
  });
}

class QuestionData {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final String topic;
  final String difficultyLevel;
  final List<String> tags;
  final String language;
  final String? imageUrl;
  final Map<String, dynamic>? additionalData;

  const QuestionData({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.topic,
    required this.difficultyLevel,
    required this.tags,
    required this.language,
    this.imageUrl,
    this.additionalData,
  });
}

class StudyMaterial {
  final String id;
  final String title;
  final String description;
  final String type; // PDF, Video, Notes, Practice Set
  final CompetitiveExamType examType;
  final String subject;
  final String topic;
  final String fileUrl;
  final int fileSizeBytes;
  final DateTime uploadDate;
  final DateTime lastUpdated;
  final double rating;
  final int downloads;
  final bool isPremium;
  final String language;
  final String author;
  final List<String> tags;

  const StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.examType,
    required this.subject,
    required this.topic,
    required this.fileUrl,
    required this.fileSizeBytes,
    required this.uploadDate,
    required this.lastUpdated,
    required this.rating,
    required this.downloads,
    required this.isPremium,
    required this.language,
    required this.author,
    required this.tags,
  });
}

class CompetitiveExamData {
  static final List<CompetitiveExamCategory> examCategories = [
    // SSC Exams
    CompetitiveExamCategory(
      id: 'ssc',
      name: 'Staff Selection Commission',
      shortName: 'SSC',
      description: 'Staff Selection Commission conducts various exams for central government jobs',
      type: CompetitiveExamType.ssc,
      icon: Icons.account_balance,
      color: Color(0xFF2196F3),
      subjects: _sscSubjects,
      examPattern: {
        'structure': 'Tier-based examination',
        'tiers': ['Tier 1', 'Tier 2', 'Tier 3', 'Tier 4'],
        'totalMarks': 200,
        'totalQuestions': 100,
        'timeLimit': 60,
        'negativeMarking': 0.25,
        'sectionalTiming': false,
      },
      eligibilityCriteria: [
        'Graduation from recognized university',
        'Age: 18-32 years',
        'Indian citizenship required',
      ],
      applicationProcess: 'Online application through SSC official website',
      upcomingExams: _sscUpcomingExams,
    ),

    // Banking Exams
    CompetitiveExamCategory(
      id: 'banking',
      name: 'Banking Exams',
      shortName: 'Banking',
      description: 'IBPS, SBI, RBI and other banking recruitment exams',
      type: CompetitiveExamType.banking,
      icon: Icons.account_balance,
      color: Color(0xFF4CAF50),
      subjects: _bankingSubjects,
      examPattern: {
        'structure': 'Preliminary and Mains examination',
        'phases': ['Prelims', 'Mains', 'Interview'],
        'totalMarks': 100,
        'totalQuestions': 100,
        'timeLimit': 60,
        'negativeMarking': 0.25,
        'sectionalTiming': true,
      },
      eligibilityCriteria: [
        'Graduation from recognized university',
        'Age: 20-30 years',
        'Computer knowledge required',
      ],
      applicationProcess: 'Online application through IBPS/SBI official websites',
      upcomingExams: _bankingUpcomingExams,
    ),

    // Railway Exams
    CompetitiveExamCategory(
      id: 'railway',
      name: 'Railway Recruitment Board',
      shortName: 'Railway',
      description: 'RRB conducts various exams for railway recruitment',
      type: CompetitiveExamType.railway,
      icon: Icons.train,
      color: Color(0xFF795548),
      subjects: _railwaySubjects,
      examPattern: {
        'structure': 'CBT-based examination',
        'phases': ['CBT 1', 'CBT 2', 'CBT 3', 'Document Verification'],
        'totalMarks': 100,
        'totalQuestions': 100,
        'timeLimit': 90,
        'negativeMarking': 0.33,
        'sectionalTiming': false,
      },
      eligibilityCriteria: [
        '10th/12th/Graduation as per post',
        'Age: 18-36 years',
        'Physical fitness required for some posts',
      ],
      applicationProcess: 'Online application through RRB official websites',
      upcomingExams: _railwayUpcomingExams,
    ),

    // Police Exams
    CompetitiveExamCategory(
      id: 'police',
      name: 'Police Recruitment',
      shortName: 'Police',
      description: 'State Police, Central Police Forces recruitment exams',
      type: CompetitiveExamType.police,
      icon: Icons.local_police,
      color: Color(0xFF607D8B),
      subjects: _policeSubjects,
      examPattern: {
        'structure': 'Written + Physical + Medical',
        'phases': ['Written Exam', 'Physical Test', 'Medical Test'],
        'totalMarks': 100,
        'totalQuestions': 100,
        'timeLimit': 120,
        'negativeMarking': 0.25,
        'sectionalTiming': false,
      },
      eligibilityCriteria: [
        '12th/Graduation as per post',
        'Age: 18-25 years',
        'Physical standards must be met',
      ],
      applicationProcess: 'Online/Offline application through respective police departments',
      upcomingExams: _policeUpcomingExams,
    ),

    // Defence Exams
    CompetitiveExamCategory(
      id: 'defence',
      name: 'Defence Forces',
      shortName: 'Defence',
      description: 'NDA, CDS, AFCAT and other defence recruitment exams',
      type: CompetitiveExamType.defence,
      icon: Icons.security,
      color: Color(0xFF8BC34A),
      subjects: _defenceSubjects,
      examPattern: {
        'structure': 'Written + SSB Interview',
        'phases': ['Written Exam', 'SSB Interview', 'Medical Test'],
        'totalMarks': 900,
        'totalQuestions': 270,
        'timeLimit': 150,
        'negativeMarking': 0.33,
        'sectionalTiming': true,
      },
      eligibilityCriteria: [
        '12th/Graduation as per exam',
        'Age: 16-24 years',
        'Medical fitness required',
      ],
      applicationProcess: 'Online application through UPSC official website',
      upcomingExams: _defenceUpcomingExams,
    ),

    // UPSC Exams
    CompetitiveExamCategory(
      id: 'upsc',
      name: 'Union Public Service Commission',
      shortName: 'UPSC',
      description: 'Civil Services, Engineering Services and other UPSC exams',
      type: CompetitiveExamType.upsc,
      icon: Icons.gavel,
      color: Color(0xFF9C27B0),
      subjects: _upscSubjects,
      examPattern: {
        'structure': 'Prelims + Mains + Interview',
        'phases': ['Prelims', 'Mains', 'Personality Test'],
        'totalMarks': 2025,
        'totalQuestions': 200,
        'timeLimit': 240,
        'negativeMarking': 0.33,
        'sectionalTiming': false,
      },
      eligibilityCriteria: [
        'Graduation from recognized university',
        'Age: 21-32 years',
        'Number of attempts limited',
      ],
      applicationProcess: 'Online application through UPSC official website',
      upcomingExams: _upscUpcomingExams,
    ),
  ];

  // SSC Subjects
  static const List<CompetitiveSubject> _sscSubjects = [
    CompetitiveSubject(
      id: 'reasoning',
      name: 'General Intelligence & Reasoning',
      shortName: 'Reasoning',
      description: 'Logical reasoning, analytical ability, problem solving',
      icon: Icons.psychology,
      color: Color(0xFF2196F3),
      totalMarks: 50,
      totalQuestions: 25,
      timeLimit: 15,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Analogies', 'Similarities', 'Differences', 'Space Visualization',
        'Problem Solving', 'Analysis', 'Judgment', 'Decision Making',
        'Visual Memory', 'Discrimination', 'Observation', 'Relationship',
        'Arithmetical Reasoning', 'Verbal and Figure Classification',
        'Arithmetic Number Series', 'Non-verbal Series'
      ],
      syllabus: [
        'Semantic Analogy',
        'Symbolic/Number Analogy',
        'Figural Analogy',
        'Semantic Classification',
        'Symbolic/Number Classification',
        'Figural Classification',
        'Semantic Series',
        'Number Series',
        'Figural Series',
        'Problem Solving',
        'Word Building',
        'Coding and De-coding',
        'Numerical Operations',
        'Symbolic Operations',
        'Trends',
        'Space Orientation',
        'Space Visualization',
        'Venn Diagrams',
        'Drawing inferences',
        'Punched hole/pattern-folding & unfolding',
        'Figural Pattern – folding and completion',
        'Indexing',
        'Address matching',
        'Date & city matching',
        'Classification of centre codes/roll numbers',
        'Small & Capital letters/numbers coding, decoding and classification',
        'Embedded Figures',
        'Critical Thinking',
        'Emotional Intelligence',
        'Social Intelligence'
      ],
    ),
    CompetitiveSubject(
      id: 'quantitative_aptitude',
      name: 'Quantitative Aptitude',
      shortName: 'Quant',
      description: 'Mathematical calculations, problem solving, data interpretation',
      icon: Icons.calculate,
      color: Color(0xFF4CAF50),
      totalMarks: 50,
      totalQuestions: 25,
      timeLimit: 15,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Number Systems', 'Computation of Whole Number', 'Decimal and Fractions',
        'Relationship between Numbers', 'Fundamental Arithmetical Operations',
        'Percentages', 'Ratio and Proportion', 'Square roots', 'Averages',
        'Interest', 'Profit and Loss', 'Discount', 'Partnership Business',
        'Mixture and Alligation', 'Time and Distance', 'Time and Work',
        'Basic Algebraic Identities', 'Linear Equations', 'Graphs of Linear Equations',
        'Triangle', 'Regular Polygons', 'Circle', 'Right Prism', 'Right Circular Cone',
        'Right Circular Cylinder', 'Sphere', 'Hemispheres', 'Rectangular Parallelepiped',
        'Triangular or Square Base', 'Trigonometric ratio', 'Degree and Radian Measures',
        'Standard Identities', 'Complementary Angles', 'Heights and Distances',
        'Histogram', 'Frequency Polygon', 'Bar-diagram', 'Pie-chart'
      ],
      syllabus: [
        'Number Systems',
        'Computation of Whole Number',
        'Decimal and Fractions',
        'Relationship between Numbers',
        'Fundamental Arithmetical Operations',
        'Percentages',
        'Ratio and Proportion',
        'Square roots',
        'Averages',
        'Interest (Simple and Compound)',
        'Profit and Loss',
        'Discount',
        'Partnership Business',
        'Mixture and Alligation',
        'Time and Distance',
        'Time and Work',
        'Basic Algebraic Identities of School Algebra',
        'Elementary surds',
        'Graphs of Linear Equations',
        'Triangle and its various kinds of centres',
        'Congruence and similarity of triangles',
        'Circle and its chords, tangents, angles subtended by chords of a circle',
        'Common tangents to two or more circles',
        'Triangle',
        'Quadrilaterals',
        'Regular Polygons',
        'Circle',
        'Right Prism',
        'Right Circular Cone',
        'Right Circular Cylinder',
        'Sphere',
        'Hemispheres',
        'Rectangular Parallelepiped',
        'Regular Right Pyramid with triangular or square base',
        'Trigonometric ratio',
        'Degree and Radian Measures',
        'Standard Identities',
        'Complementary angles',
        'Heights and Distances',
        'Histogram',
        'Frequency polygon',
        'Bar diagram',
        'Pie chart'
      ],
    ),
    CompetitiveSubject(
      id: 'english',
      name: 'English Comprehension',
      shortName: 'English',
      description: 'Grammar, vocabulary, comprehension, writing skills',
      icon: Icons.language,
      color: Color(0xFFFF9800),
      totalMarks: 50,
      totalQuestions: 25,
      timeLimit: 15,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Vocabulary', 'Grammar', 'Sentence Structure', 'Synonyms',
        'Antonyms', 'Sentence Completion', 'Phrases and Idioms',
        'One Word Substitution', 'Improvement of Sentences',
        'Active/Passive Voice', 'Conversion into Direct/Indirect narration',
        'Shuffling of Sentence parts', 'Shuffling of Sentences in a passage',
        'Cloze Passage', 'Comprehension Passage'
      ],
      syllabus: [
        'Spot the Error',
        'Fill in the Blanks',
        'Synonyms/Homonyms',
        'Antonyms',
        'Spelling/Detecting Misspelled words',
        'Idioms & Phrases',
        'One word substitution',
        'Improvement of Sentences',
        'Active/Passive Voice of Verbs',
        'Conversion into Direct/Indirect narration',
        'Shuffling of Sentence parts',
        'Shuffling of Sentences in a passage',
        'Cloze Passage',
        'Comprehension Passage'
      ],
    ),
    CompetitiveSubject(
      id: 'general_awareness',
      name: 'General Awareness',
      shortName: 'GA',
      description: 'Current affairs, history, geography, science, culture',
      icon: Icons.public,
      color: Color(0xFFE91E63),
      totalMarks: 50,
      totalQuestions: 25,
      timeLimit: 15,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'India and its neighbouring countries', 'History', 'Culture',
        'Geography', 'Economic Scene', 'General Policy', 'Scientific Research',
        'Current Affairs', 'Books and Authors', 'Sports', 'Important Schemes',
        'Important Days', 'Portfolio', 'People in News'
      ],
      syllabus: [
        'India and its neighbouring countries especially pertaining to History',
        'Culture',
        'Geography',
        'Economic Scene',
        'General policy on important issues',
        'Scientific Research',
        'Current Affairs',
        'Books and Authors',
        'Sports',
        'Important Schemes',
        'Important Days & Dates',
        'Portfolio',
        'People in News'
      ],
    ),
  ];

  // Banking Subjects
  static const List<CompetitiveSubject> _bankingSubjects = [
    CompetitiveSubject(
      id: 'reasoning_ability',
      name: 'Reasoning Ability',
      shortName: 'Reasoning',
      description: 'Logical reasoning, puzzles, data sufficiency',
      icon: Icons.psychology,
      color: Color(0xFF2196F3),
      totalMarks: 35,
      totalQuestions: 35,
      timeLimit: 20,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Moderate to Difficult',
      topics: [
        'Logical Reasoning', 'Alphanumeric Series', 'Ranking/Direction/Alphabet Test',
        'Data Sufficiency', 'Coded Inequalities', 'Seating Arrangement',
        'Puzzle', 'Tabulation', 'Syllogism', 'Blood Relations',
        'Input Output', 'Coding Decoding'
      ],
      syllabus: [
        'Logical Reasoning',
        'Alphanumeric Series',
        'Ranking/Direction/Alphabet Test',
        'Data Sufficiency',
        'Coded Inequalities',
        'Seating Arrangement',
        'Puzzle',
        'Tabulation',
        'Syllogism',
        'Blood Relations',
        'Input Output',
        'Coding Decoding'
      ],
    ),
    CompetitiveSubject(
      id: 'numerical_ability',
      name: 'Numerical Ability',
      shortName: 'Numerical',
      description: 'Mathematical calculations, data interpretation, number series',
      icon: Icons.calculate,
      color: Color(0xFF4CAF50),
      totalMarks: 35,
      totalQuestions: 35,
      timeLimit: 20,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Moderate to Difficult',
      topics: [
        'Data Interpretation', 'Inequalities', 'Number Series', 'Approximation & Simplification',
        'Profit & Loss', 'Simple Interest & Compound Interest', 'Partnership',
        'Mixture & Alligation', 'Time & Work', 'Time & Distance',
        'Probability', 'Permutation & Combination', 'Average', 'Ratio & Proportion',
        'Percentage', 'Age', 'Boats & Streams', 'Pipes & Cisterns'
      ],
      syllabus: [
        'Data Interpretation',
        'Inequalities (Quadratic)',
        'Number Series',
        'Approximation and Simplification',
        'Profit & Loss',
        'Simple Interest & Compound Interest',
        'Partnership',
        'Mixture & Alligation',
        'Time & Work',
        'Time & Distance',
        'Probability',
        'Permutation & Combination',
        'Average',
        'Ratio & Proportion',
        'Percentage',
        'Age',
        'Boats & Streams',
        'Pipes & Cisterns'
      ],
    ),
    CompetitiveSubject(
      id: 'english_language',
      name: 'English Language',
      shortName: 'English',
      description: 'Reading comprehension, grammar, vocabulary',
      icon: Icons.language,
      color: Color(0xFFFF9800),
      totalMarks: 30,
      totalQuestions: 30,
      timeLimit: 20,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Moderate',
      topics: [
        'Reading Comprehension', 'Cloze Test', 'Para Jumbles', 'Miscellaneous',
        'Fill in the blanks', 'Multiple Meaning/Error Spotting', 'Paragraph Completion'
      ],
      syllabus: [
        'Reading Comprehension',
        'Cloze Test',
        'Para Jumbles',
        'Miscellaneous',
        'Fill in the blanks',
        'Multiple Meaning/Error Spotting',
        'Paragraph Completion'
      ],
    ),
  ];

  // Railway Subjects
  static const List<CompetitiveSubject> _railwaySubjects = [
    CompetitiveSubject(
      id: 'mathematics',
      name: 'Mathematics',
      shortName: 'Maths',
      description: 'Mathematical calculations, algebra, geometry',
      icon: Icons.calculate,
      color: Color(0xFF2196F3),
      totalMarks: 25,
      totalQuestions: 25,
      timeLimit: 30,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.33,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Number System', 'BODMAS', 'Decimals', 'Fractions', 'LCM HCF',
        'Ratio and Proportions', 'Percentages', 'Mensuration',
        'Time and Work', 'Time and Distance', 'Simple and Compound Interest',
        'Profit and Loss', 'Algebra', 'Geometry', 'Trigonometry',
        'Elementary Statistics', 'Square Root', 'Age Calculations',
        'Calendar & Clock', 'Pipes & Cistern'
      ],
      syllabus: [
        'Number System',
        'BODMAS',
        'Decimals',
        'Fractions',
        'LCM, HCF',
        'Ratio and Proportions',
        'Percentages',
        'Mensuration',
        'Time and Work',
        'Time and Distance',
        'Simple and Compound Interest',
        'Profit and Loss',
        'Algebra',
        'Geometry and Trigonometry',
        'Elementary Statistics',
        'Square Root',
        'Age Calculations',
        'Calendar & Clock',
        'Pipes & Cistern'
      ],
    ),
    CompetitiveSubject(
      id: 'general_intelligence',
      name: 'General Intelligence and Reasoning',
      shortName: 'Reasoning',
      description: 'Logical reasoning, analytical ability',
      icon: Icons.psychology,
      color: Color(0xFF4CAF50),
      totalMarks: 30,
      totalQuestions: 30,
      timeLimit: 30,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.33,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Analogies', 'Alphabetical and Number Series', 'Mathematical operations',
        'Relationships', 'Syllogism', 'Jumbling', 'Venn Diagram',
        'Data Interpretation and Sufficiency', 'Conclusions and Decision Making',
        'Similarities and Differences', 'Analytical reasoning',
        'Classification', 'Directions', 'Statement Arguments'
      ],
      syllabus: [
        'Analogies',
        'Alphabetical and Number Series',
        'Mathematical operations',
        'Relationships',
        'Syllogism',
        'Jumbling',
        'Venn Diagram',
        'Data Interpretation and Sufficiency',
        'Conclusions and Decision Making',
        'Similarities and Differences',
        'Analytical reasoning',
        'Classification',
        'Directions',
        'Statement Arguments'
      ],
    ),
    CompetitiveSubject(
      id: 'general_science',
      name: 'General Science',
      shortName: 'Science',
      description: 'Physics, chemistry, life sciences',
      icon: Icons.science,
      color: Color(0xFFFF5722),
      totalMarks: 25,
      totalQuestions: 25,
      timeLimit: 30,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.33,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Physics', 'Chemistry', 'Life Sciences'
      ],
      syllabus: [
        'Physics: Force and Motion, Work, Power and Energy',
        'Chemistry: Matter and its States, Chemical Reactions',
        'Life Sciences: Life Processes in Plants and Animals, Heredity and Evolution'
      ],
    ),
    CompetitiveSubject(
      id: 'general_awareness',
      name: 'General Awareness and Current Affairs',
      shortName: 'GA',
      description: 'Current affairs, static GK, history, geography',
      icon: Icons.public,
      color: Color(0xFF9C27B0),
      totalMarks: 20,
      totalQuestions: 20,
      timeLimit: 30,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.33,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Science & Technology', 'Sports', 'Culture', 'Personalities',
        'Economics', 'Politics', 'Current Affairs'
      ],
      syllabus: [
        'Science & Technology',
        'Sports',
        'Culture',
        'Personalities',
        'Economics',
        'Politics and other subjects of importance',
        'Current Affairs'
      ],
    ),
  ];

  // Police Subjects
  static const List<CompetitiveSubject> _policeSubjects = [
    CompetitiveSubject(
      id: 'general_knowledge',
      name: 'General Knowledge',
      shortName: 'GK',
      description: 'History, geography, civics, current affairs',
      icon: Icons.book,
      color: Color(0xFF2196F3),
      totalMarks: 25,
      totalQuestions: 25,
      timeLimit: 30,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Indian History', 'Geography of India', 'Indian Polity',
        'Indian Economy', 'General Science', 'Current Affairs',
        'Books and Authors', 'Awards and Honours', 'Sports'
      ],
      syllabus: [
        'Indian History',
        'Geography of India',
        'Indian Polity',
        'Indian Economy',
        'General Science',
        'Current Affairs',
        'Books and Authors',
        'Awards and Honours',
        'Sports'
      ],
    ),
    CompetitiveSubject(
      id: 'general_hindi',
      name: 'General Hindi',
      shortName: 'Hindi',
      description: 'Hindi grammar, comprehension, vocabulary',
      icon: Icons.language,
      color: Color(0xFF4CAF50),
      totalMarks: 25,
      totalQuestions: 25,
      timeLimit: 30,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Hindi Vyakaran', 'Vilom', 'Paryayvachi', 'Vakya Correction',
        'Idioms & Phrases', 'Comprehension'
      ],
      syllabus: [
        'Hindi Vyakaran',
        'Vilom',
        'Paryayvachi',
        'Vakya Correction',
        'Idioms & Phrases',
        'Comprehension'
      ],
    ),
    CompetitiveSubject(
      id: 'numerical_mathematical_ability',
      name: 'Numerical & Mathematical Ability',
      shortName: 'Numerical',
      description: 'Basic mathematics, mental ability',
      icon: Icons.calculate,
      color: Color(0xFFFF9800),
      totalMarks: 25,
      totalQuestions: 25,
      timeLimit: 30,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Number System', 'Simplification', 'Decimals and Fraction',
        'HCF and LCM', 'Ratio and Proportion', 'Percentage',
        'Profit and Loss', 'Simple and Compound Interest',
        'Time and Work', 'Time and Distance', 'Average',
        'Mensuration', 'Data Interpretation'
      ],
      syllabus: [
        'Number System',
        'Simplification',
        'Decimals and Fraction',
        'HCF and LCM',
        'Ratio and Proportion',
        'Percentage',
        'Profit and Loss',
        'Simple and Compound Interest',
        'Time and Work',
        'Time and Distance',
        'Average',
        'Mensuration - 2D, 3D',
        'Data Interpretation'
      ],
    ),
    CompetitiveSubject(
      id: 'mental_ability_iq_test',
      name: 'Mental Ability/IQ Test',
      shortName: 'Mental Ability',
      description: 'Logical reasoning, analytical skills',
      icon: Icons.psychology,
      color: Color(0xFFE91E63),
      totalMarks: 25,
      totalQuestions: 25,
      timeLimit: 30,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Easy to Moderate',
      topics: [
        'Logical Diagrams', 'Symbol-Relationship Interpretation',
        'Codification', 'Perception Test', 'Word formation Test',
        'Letter and number series', 'Word and alphabet Analogy',
        'Common Sense Test', 'Letter and number coding',
        'Direction sense Test', 'Logical interpretation of data',
        'Forcefulness of argument', 'Determining implied meanings'
      ],
      syllabus: [
        'Logical Diagrams',
        'Symbol-Relationship Interpretation',
        'Codification',
        'Perception Test',
        'Word formation Test',
        'Letter and number series',
        'Word and alphabet Analogy',
        'Common Sense Test',
        'Letter and number coding',
        'Direction sense Test',
        'Logical interpretation of data',
        'Forcefulness of argument',
        'Determining implied meanings'
      ],
    ),
  ];

  // Defence Subjects
  static const List<CompetitiveSubject> _defenceSubjects = [
    CompetitiveSubject(
      id: 'mathematics_defence',
      name: 'Mathematics',
      shortName: 'Maths',
      description: 'Advanced mathematics for defence exams',
      icon: Icons.calculate,
      color: Color(0xFF2196F3),
      totalMarks: 300,
      totalQuestions: 120,
      timeLimit: 150,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.33,
      difficultyLevel: 'Moderate to Difficult',
      topics: [
        'Algebra', 'Matrices and Determinants', 'Trigonometry',
        'Analytical Geometry of 2D and 3D', 'Differential Calculus',
        'Integral Calculus and Differential Equations', 'Vector Algebra',
        'Statistics and Probability'
      ],
      syllabus: [
        'Algebra',
        'Matrices and Determinants',
        'Trigonometry',
        'Analytical Geometry of 2D and 3D',
        'Differential Calculus',
        'Integral Calculus and Differential Equations',
        'Vector Algebra',
        'Statistics and Probability'
      ],
    ),
    CompetitiveSubject(
      id: 'general_ability_test',
      name: 'General Ability Test',
      shortName: 'GAT',
      description: 'English and general knowledge',
      icon: Icons.language,
      color: Color(0xFF4CAF50),
      totalMarks: 600,
      totalQuestions: 150,
      timeLimit: 150,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.33,
      difficultyLevel: 'Moderate',
      topics: [
        'English', 'General Knowledge', 'Physics', 'Chemistry',
        'General Science', 'History', 'Geography', 'Current Events'
      ],
      syllabus: [
        'English: Grammar and usage, vocabulary, comprehension and cohesion',
        'General Knowledge: Physics, Chemistry, General Science, Social Studies, Geography, Current Events'
      ],
    ),
  ];

  // UPSC Subjects
  static const List<CompetitiveSubject> _upscSubjects = [
    CompetitiveSubject(
      id: 'general_studies_paper1',
      name: 'General Studies Paper I',
      shortName: 'GS Paper I',
      description: 'Current events, history, geography',
      icon: Icons.book,
      color: Color(0xFF2196F3),
      totalMarks: 200,
      totalQuestions: 100,
      timeLimit: 120,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.33,
      difficultyLevel: 'Moderate to Difficult',
      topics: [
        'Current events of national and international importance',
        'History of India and Indian National Movement',
        'Indian and World Geography', 'Indian Polity and Governance',
        'Economic and Social Development', 'Environmental Ecology',
        'Biodiversity and Climate Change', 'General Science'
      ],
      syllabus: [
        'Current events of national and international importance',
        'History of India and Indian National Movement',
        'Indian and World Geography - Physical, Social, Economic Geography of India and the World',
        'Indian Polity and Governance - Constitution, Political System, Panchayati Raj, Public Policy, Rights Issues, etc.',
        'Economic and Social Development - Sustainable Development, Poverty, Inclusion, Demographics, Social Sector initiatives, etc.',
        'General issues on Environmental Ecology, Bio-diversity and Climate Change',
        'General Science'
      ],
    ),
    CompetitiveSubject(
      id: 'general_studies_paper2',
      name: 'General Studies Paper II (CSAT)',
      shortName: 'GS Paper II',
      description: 'Comprehension, reasoning, problem solving',
      icon: Icons.psychology,
      color: Color(0xFF4CAF50),
      totalMarks: 200,
      totalQuestions: 80,
      timeLimit: 120,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.33,
      difficultyLevel: 'Moderate',
      topics: [
        'Comprehension', 'Interpersonal skills including communication skills',
        'Logical reasoning and analytical ability', 'Decision making and problem solving',
        'General mental ability', 'Basic numeracy', 'Data interpretation',
        'English Language Comprehension skills'
      ],
      syllabus: [
        'Comprehension',
        'Interpersonal skills including communication skills',
        'Logical reasoning and analytical ability',
        'Decision-making and problem-solving',
        'General mental ability',
        'Basic numeracy (numbers and their relations, orders of magnitude, etc.)',
        'Data interpretation (charts, graphs, tables, data sufficiency etc.)',
        'English Language Comprehension skills (Class X level)'
      ],
    ),
  ];

  // Sample upcoming exams data
  static final List<ExamSchedule> _sscUpcomingExams = [
    ExamSchedule(
      examName: 'SSC CGL 2024',
      examCode: 'SSC-CGL-2024',
      applicationStart: DateTime.now().add(const Duration(days: 30)),
      applicationEnd: DateTime.now().add(const Duration(days: 60)),
      examDate: DateTime.now().add(const Duration(days: 120)),
      resultDate: DateTime.now().add(const Duration(days: 180)),
      status: 'upcoming',
      officialWebsite: 'https://ssc.nic.in',
      importantDates: [
        'Application Start: ${DateTime.now().add(const Duration(days: 30)).toString().split(' ')[0]}',
        'Application End: ${DateTime.now().add(const Duration(days: 60)).toString().split(' ')[0]}',
        'Admit Card: ${DateTime.now().add(const Duration(days: 100)).toString().split(' ')[0]}',
        'Exam Date: ${DateTime.now().add(const Duration(days: 120)).toString().split(' ')[0]}'
      ],
      examFees: {
        'General/OBC': 100,
        'SC/ST/PWD/Ex-Servicemen': 0,
      },
      notification: 'SSC CGL 2024 notification released. Apply now!',
    ),
  ];

  static final List<ExamSchedule> _bankingUpcomingExams = [
    ExamSchedule(
      examName: 'IBPS PO 2024',
      examCode: 'IBPS-PO-2024',
      applicationStart: DateTime.now().add(const Duration(days: 15)),
      applicationEnd: DateTime.now().add(const Duration(days: 45)),
      examDate: DateTime.now().add(const Duration(days: 90)),
      resultDate: DateTime.now().add(const Duration(days: 150)),
      status: 'upcoming',
      officialWebsite: 'https://ibps.in',
      importantDates: [
        'Application Start: ${DateTime.now().add(const Duration(days: 15)).toString().split(' ')[0]}',
        'Application End: ${DateTime.now().add(const Duration(days: 45)).toString().split(' ')[0]}',
        'Prelims Exam: ${DateTime.now().add(const Duration(days: 90)).toString().split(' ')[0]}',
        'Mains Exam: ${DateTime.now().add(const Duration(days: 120)).toString().split(' ')[0]}'
      ],
      examFees: {
        'General/OBC/EWS': 850,
        'SC/ST/PWD': 175,
      },
      notification: 'IBPS PO 2024 recruitment notification out. 4135 vacancies.',
    ),
  ];

  static final List<ExamSchedule> _railwayUpcomingExams = [
    ExamSchedule(
      examName: 'RRB NTPC 2024',
      examCode: 'RRB-NTPC-2024',
      applicationStart: DateTime.now().add(const Duration(days: 45)),
      applicationEnd: DateTime.now().add(const Duration(days: 75)),
      examDate: DateTime.now().add(const Duration(days: 135)),
      resultDate: DateTime.now().add(const Duration(days: 200)),
      status: 'upcoming',
      officialWebsite: 'https://rrbcdg.gov.in',
      importantDates: [
        'Application Start: ${DateTime.now().add(const Duration(days: 45)).toString().split(' ')[0]}',
        'Application End: ${DateTime.now().add(const Duration(days: 75)).toString().split(' ')[0]}',
        'CBT 1: ${DateTime.now().add(const Duration(days: 135)).toString().split(' ')[0]}',
      ],
      examFees: {
        'General/OBC': 500,
        'SC/ST/PWD/Ex-Servicemen': 250,
      },
      notification: 'RRB NTPC 2024 recruitment coming soon. 35000+ vacancies expected.',
    ),
  ];

  static final List<ExamSchedule> _policeUpcomingExams = [
    ExamSchedule(
      examName: 'UP Police Constable 2024',
      examCode: 'UPP-CONST-2024',
      applicationStart: DateTime.now().add(const Duration(days: 20)),
      applicationEnd: DateTime.now().add(const Duration(days: 50)),
      examDate: DateTime.now().add(const Duration(days: 110)),
      resultDate: DateTime.now().add(const Duration(days: 170)),
      status: 'upcoming',
      officialWebsite: 'https://uppbpb.gov.in',
      importantDates: [
        'Application Start: ${DateTime.now().add(const Duration(days: 20)).toString().split(' ')[0]}',
        'Application End: ${DateTime.now().add(const Duration(days: 50)).toString().split(' ')[0]}',
        'Written Exam: ${DateTime.now().add(const Duration(days: 110)).toString().split(' ')[0]}',
      ],
      examFees: {
        'General/OBC': 400,
        'SC/ST': 200,
      },
      notification: 'UP Police Constable 2024 recruitment notification expected soon.',
    ),
  ];

  static final List<ExamSchedule> _defenceUpcomingExams = [
    ExamSchedule(
      examName: 'NDA 2024 (I)',
      examCode: 'NDA-2024-I',
      applicationStart: DateTime.now().add(const Duration(days: 10)),
      applicationEnd: DateTime.now().add(const Duration(days: 40)),
      examDate: DateTime.now().add(const Duration(days: 100)),
      resultDate: DateTime.now().add(const Duration(days: 160)),
      status: 'upcoming',
      officialWebsite: 'https://upsc.gov.in',
      importantDates: [
        'Application Start: ${DateTime.now().add(const Duration(days: 10)).toString().split(' ')[0]}',
        'Application End: ${DateTime.now().add(const Duration(days: 40)).toString().split(' ')[0]}',
        'Written Exam: ${DateTime.now().add(const Duration(days: 100)).toString().split(' ')[0]}',
      ],
      examFees: {
        'All Categories': 100,
      },
      notification: 'NDA 2024 (I) application process starting soon.',
    ),
  ];

  static final List<ExamSchedule> _upscUpcomingExams = [
    ExamSchedule(
      examName: 'UPSC Civil Services 2024',
      examCode: 'UPSC-CS-2024',
      applicationStart: DateTime.now().add(const Duration(days: 25)),
      applicationEnd: DateTime.now().add(const Duration(days: 55)),
      examDate: DateTime.now().add(const Duration(days: 125)),
      resultDate: DateTime.now().add(const Duration(days: 365)),
      status: 'upcoming',
      officialWebsite: 'https://upsc.gov.in',
      importantDates: [
        'Application Start: ${DateTime.now().add(const Duration(days: 25)).toString().split(' ')[0]}',
        'Application End: ${DateTime.now().add(const Duration(days: 55)).toString().split(' ')[0]}',
        'Prelims: ${DateTime.now().add(const Duration(days: 125)).toString().split(' ')[0]}',
        'Mains: ${DateTime.now().add(const Duration(days: 185)).toString().split(' ')[0]}'
      ],
      examFees: {
        'General/OBC/EWS': 200,
        'SC/ST/PWD/Women': 25,
      },
      notification: 'UPSC Civil Services 2024 notification to be released soon. 1105 vacancies.',
    ),
  ];

  // Mock Test Series Data
  static List<MockTestSeries> getMockTestSeries({CompetitiveExamType? examType, String? examSubType}) {
    return _mockTestSeriesData.where((test) {
      bool matchesType = examType == null || test.examType == examType;
      bool matchesSubType = examSubType == null || test.examSubType.toLowerCase().contains(examSubType.toLowerCase());
      return matchesType && matchesSubType;
    }).toList();
  }

  static final List<MockTestSeries> _mockTestSeriesData = [
    // SSC Mock Tests
    MockTestSeries(
      id: 'ssc_cgl_full_1',
      title: 'SSC CGL Tier 1 - Full Mock Test 1',
      description: 'Complete mock test based on latest SSC CGL pattern',
      examType: CompetitiveExamType.ssc,
      examSubType: 'SSC CGL',
      testType: TestType.fullTest,
      sections: [], // Will be populated separately
      totalQuestions: 100,
      totalMarks: 200,
      timeLimit: 60,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Moderate',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      validUntil: DateTime.now().add(const Duration(days: 365)),
      attempts: 0,
      averageScore: 78.5,
      totalAttempts: 12450,
      isPremium: false,
      language: 'Bilingual',
    ),
    MockTestSeries(
      id: 'ssc_reasoning_section_1',
      title: 'SSC Reasoning - Sectional Test 1',
      description: 'Reasoning ability test for SSC exams',
      examType: CompetitiveExamType.ssc,
      examSubType: 'SSC CGL',
      testType: TestType.sectionTest,
      sections: [], // Will be populated separately
      totalQuestions: 25,
      totalMarks: 50,
      timeLimit: 15,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Easy',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      validUntil: DateTime.now().add(const Duration(days: 365)),
      attempts: 0,
      averageScore: 82.1,
      totalAttempts: 8920,
      isPremium: false,
      language: 'Bilingual',
    ),

    // Banking Mock Tests
    MockTestSeries(
      id: 'ibps_po_prelims_1',
      title: 'IBPS PO Prelims - Mock Test 1',
      description: 'Complete IBPS PO Prelims mock test',
      examType: CompetitiveExamType.banking,
      examSubType: 'IBPS PO',
      testType: TestType.mockTest,
      sections: [], // Will be populated separately
      totalQuestions: 100,
      totalMarks: 100,
      timeLimit: 60,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Moderate',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      validUntil: DateTime.now().add(const Duration(days: 365)),
      attempts: 0,
      averageScore: 75.8,
      totalAttempts: 15670,
      isPremium: false,
      language: 'English',
    ),

    // Railway Mock Tests
    MockTestSeries(
      id: 'rrb_ntpc_cbt1_1',
      title: 'RRB NTPC CBT 1 - Mock Test 1',
      description: 'RRB NTPC Computer Based Test 1 practice',
      examType: CompetitiveExamType.railway,
      examSubType: 'RRB NTPC',
      testType: TestType.mockTest,
      sections: [], // Will be populated separately
      totalQuestions: 100,
      totalMarks: 100,
      timeLimit: 90,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.33,
      difficultyLevel: 'Easy',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      validUntil: DateTime.now().add(const Duration(days: 365)),
      attempts: 0,
      averageScore: 68.9,
      totalAttempts: 11230,
      isPremium: false,
      language: 'Bilingual',
    ),

    // Police Mock Tests
    MockTestSeries(
      id: 'up_police_constable_1',
      title: 'UP Police Constable - Mock Test 1',
      description: 'UP Police Constable recruitment test practice',
      examType: CompetitiveExamType.police,
      examSubType: 'UP Police Constable',
      testType: TestType.mockTest,
      sections: [], // Will be populated separately
      totalQuestions: 100,
      totalMarks: 100,
      timeLimit: 120,
      hasNegativeMarking: true,
      negativeMarkingRatio: 0.25,
      difficultyLevel: 'Easy',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      validUntil: DateTime.now().add(const Duration(days: 365)),
      attempts: 0,
      averageScore: 71.2,
      totalAttempts: 9680,
      isPremium: false,
      language: 'Hindi',
    ),
  ];

  // Study Materials Data
  static List<StudyMaterial> getStudyMaterials({CompetitiveExamType? examType, String? subject}) {
    return _studyMaterialsData.where((material) {
      bool matchesType = examType == null || material.examType == examType;
      bool matchesSubject = subject == null || material.subject.toLowerCase().contains(subject.toLowerCase());
      return matchesType && matchesSubject;
    }).toList();
  }

  static final List<StudyMaterial> _studyMaterialsData = [
    StudyMaterial(
      id: 'ssc_reasoning_notes',
      title: 'SSC Reasoning Complete Notes',
      description: 'Comprehensive reasoning notes for all SSC exams with solved examples',
      type: 'PDF',
      examType: CompetitiveExamType.ssc,
      subject: 'Reasoning',
      topic: 'Complete Syllabus',
      fileUrl: 'https://example.com/ssc_reasoning_notes.pdf',
      fileSizeBytes: 5242880, // 5MB
      uploadDate: DateTime.now().subtract(const Duration(days: 10)),
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      rating: 4.6,
      downloads: 12450,
      isPremium: false,
      language: 'Bilingual',
      author: 'Expert Faculty',
      tags: ['reasoning', 'ssc', 'complete-notes', 'solved-examples'],
    ),
    StudyMaterial(
      id: 'banking_quantitative_aptitude',
      title: 'Banking Quantitative Aptitude - Shortcut Methods',
      description: 'Quick methods and tricks for quantitative aptitude in banking exams',
      type: 'PDF',
      examType: CompetitiveExamType.banking,
      subject: 'Quantitative Aptitude',
      topic: 'Shortcut Methods',
      fileUrl: 'https://example.com/banking_quant_shortcuts.pdf',
      fileSizeBytes: 3145728, // 3MB
      uploadDate: DateTime.now().subtract(const Duration(days: 5)),
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      rating: 4.8,
      downloads: 8920,
      isPremium: true,
      language: 'English',
      author: 'Banking Expert',
      tags: ['banking', 'quantitative-aptitude', 'shortcuts', 'tricks'],
    ),
    StudyMaterial(
      id: 'railway_previous_papers',
      title: 'RRB NTPC Previous Year Papers (2020-2023)',
      description: 'Collection of previous year question papers with solutions',
      type: 'PDF',
      examType: CompetitiveExamType.railway,
      subject: 'All Subjects',
      topic: 'Previous Year Papers',
      fileUrl: 'https://example.com/rrb_ntpc_previous_papers.pdf',
      fileSizeBytes: 8388608, // 8MB
      uploadDate: DateTime.now().subtract(const Duration(days: 15)),
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      rating: 4.7,
      downloads: 15670,
      isPremium: false,
      language: 'Bilingual',
      author: 'Railway Preparation Team',
      tags: ['railway', 'rrb-ntpc', 'previous-year', 'solutions'],
    ),
  ];

  // Utility methods
  static CompetitiveExamCategory? getExamCategoryById(String id) {
    try {
      return examCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<CompetitiveExamCategory> getExamCategoriesByType(CompetitiveExamType type) {
    return examCategories.where((category) => category.type == type).toList();
  }

  static List<CompetitiveSubject> getSubjectsByExamType(CompetitiveExamType type) {
    final category = examCategories.where((cat) => cat.type == type).first;
    return category.subjects;
  }

  static List<String> getAllExamTypes() {
    return examCategories.map((category) => category.name).toList();
  }

  static List<String> getAllSubjects() {
    final List<String> subjects = [];
    for (final category in examCategories) {
      for (final subject in category.subjects) {
        if (!subjects.contains(subject.name)) {
          subjects.add(subject.name);
        }
      }
    }
    return subjects;
  }
}
