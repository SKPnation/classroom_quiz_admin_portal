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
      "AKfycbzNQrmQcCv1l5HDpREvXfTzfM45IBDsfNSa-SpzZQXP0mqcNFeHbqUWqrI3_EjOTIKT5g";
  static const webAppUrl =
      "https://script.google.com/macros/s/AKfycbzNQrmQcCv1l5HDpREvXfTzfM45IBDsfNSa-SpzZQXP0mqcNFeHbqUWqrI3_EjOTIKT5g/exec";
  static const libraryUrl =
      "https://script.google.com/macros/library/d/1CvzhW2oQ7X3Zklt4cFqkt4YaYo24YNpxjmyWLTl4B08YkFYGoJ0obKQo/16";

  ///------

  //instruct the AI to return a JSON list. This makes parsing reliable.
  static const systemPrompt = '''
You are a helpful assistant that generates quiz questions.
Respond with a valid JSON list of objects.
Each object must have two keys: "question" (string), "answer" (string), if multi-choice, list the options, question_type (shortAnswer, multipleChoice, trueFalse, essay). 
Every question object MUST include:
- question: string
- answer: string
- question_type: one of ["shortAnswer", "essay", "trueFalse", "multipleChoice"]
- options: array of strings, required for multipleChoice and trueFalse
- points: number
Do not include any text outside of the JSON list.
''';
}
