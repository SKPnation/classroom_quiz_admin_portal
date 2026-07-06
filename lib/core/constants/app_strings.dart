class AppStrings {
  /// PRIMARY -------------
  static const String dashboardTitle = "Dashboard";
  static const String createQuizTitle = "Create Quiz";

  //QUIZZES
  static const String aiGeneratorTitle = "AI Generator";
  static const String quizEditorTitle = "Quiz Editor";
  static const String questionBankTitle = "Question Bank";
  static const String publishedQuizzesTitle = "Published Quizzes";

  //DELIVERY
  static const String schedulesTitle = "Schedules/Assignments";
  static const String classesTitle = "Classes";
  static const String studentsTitle = "Students";

  /// -------------- PRIMARY

  /// GRADING & INSIGHTS -----------
  static const String resultsTitle = "Results";
  static const String gradingQueueTitle = "Grading Queue";

  //Analytics
  static const String itemAnalysisTitle = "Item Analysis";
  static const String studentProgressTitle = "Student Progress";

  /// ---------- GRADING & INSIGHTS

  /// RESOURCES
  static const String mediaLibraryTitle = "Media Library";
  static const String settingsTitle = "Settings";

  //Dashboard Content -- Info Card Titles
  static const String totalQuizzes = "Total Quizzes";
  static const String avgClassScore = "Average Class Score";
  static const String pendingGrading = "Pending Grading";
  static const String upcomingQuizzes = "Upcoming Quizzes";

  static const String performanceOverview = "Performance Overview";
  static const String recentQuizzes = "Recent Quizzes";

  //Create Quiz
  static const String startNewQuiz = "Start a new quiz";

  static const String quizzesTitle = "Quizzes";
  static const String deliveryTitle = "Delivery";
  static const String gradingInsightsTitle = "Grading & Insights";
  static const String resourcesTitle = "Resources";

  static const String quickActionsTitle = "Quick Actions";
  static const String defaultsTitle = "Defaults";

  ///-------------------------FIRESTORE COLLECTIONS----------------------------------
  static const String lecturer = "lecturer";
  static const String members = "members";
  static const String users = "users";
  static const String organisations = "orgs";
  static const String gradedAttempts = "gradedAttempts";

  static String get templates => 'templates';

  static String get integrations => "integrations";

  ///------ GOOGLE APPS SCRIPT API VARIABLES
  static const deploymentID =
      "AKfycbyB_rrVYbi8UxMiIWlxjdVe93GXSRs8Bl8S5nDZW5j-Vhd0ZCktHNFo8LksuXOhRp6o7g";
  static const webAppUrl =
      "https://script.google.com/macros/s/AKfycbyB_rrVYbi8UxMiIWlxjdVe93GXSRs8Bl8S5nDZW5j-Vhd0ZCktHNFo8LksuXOhRp6o7g/exec";
  static const libraryUrl =
      "https://script.google.com/macros/library/d/1CvzhW2oQ7X3Zklt4cFqkt4YaYo24YNpxjmyWLTl4B08YkFYGoJ0obKQo/17";

  ///------

  //instruct the AI to return a JSON list. This makes parsing reliable.
  static const systemPrompt = '''
You are a quiz question generator.

CRITICAL RULES:
1. If the user specifies a question type (e.g. "only multiple choice", "only true/false"), you MUST generate ONLY that type. No exceptions.
2. If the user specifies a number of questions, generate exactly that number.
3. If no type is specified, generate a mix of types.

Respond with a valid JSON object in this exact format:
{
  "questions": [
    {
      "question": "string",
      "answer": "string",
      "question_type": "multipleChoice | shortAnswer | trueFalse | essay",
      "options": ["option1", "option2", "option3", "option4"],
      "points": 1
    }
  ]
}

Rules for each type:
- multipleChoice: must have exactly 4 options, answer must match one option exactly
- trueFalse: options must be exactly ["True", "False"], answer must be "True" or "False"
- shortAnswer: options must be an empty array []
- essay: options must be an empty array []

Do not include any text outside of the JSON object.
''';
}
