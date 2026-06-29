import 'package:classroom_quiz_admin_portal/features/grading_insights/data/models/question_result_model.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/data/models/student_answer_model.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/presentation/pages/grading_queue.dart';

enum GradingStatus { pending, aiSuggested, flagged, reviewed }

class GradingAttemptModel {
  final String id;
  final String orgId;
  final String createdBy;

  final String publishedQuizId;
  final String quizTitle;

  final String studentFirstName;
  final String studentLastName;
  final String studentName;
  final String studentId;
  final String? studentEmail;

  final double score;
  final double maxScore;
  final double percentage;

  final double aiConfidence;
  final GradingStatus status; // graded, needs_review, flagged, pending
  final String feedback;
  final String gradingMethod; // ai, manual, hybrid

  final List<QuestionResultModel> questionResults;
  final List<StudentAnswerModel> answers;

  final DateTime submittedAt;
  final DateTime gradedAt;

  final String formId;

  GradingAttemptModel({
    required this.id,
    required this.orgId,
    required this.createdBy,
    required this.publishedQuizId,
    required this.quizTitle,
    required this.studentFirstName,
    required this.studentLastName,
    required this.studentName,
    required this.studentId,
    this.studentEmail,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.aiConfidence,
    required this.status,
    required this.feedback,
    required this.gradingMethod,
    required this.questionResults,
    required this.answers,
    required this.submittedAt,
    required this.gradedAt,
    required this.formId,
  });

  factory GradingAttemptModel.fromMap(Map<String, dynamic> map) {
    return GradingAttemptModel(
      id: map['id'] ?? '',
      orgId: map['orgId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      publishedQuizId: map['publishedQuizId'] ?? '',
      quizTitle: map['quizTitle'] ?? '',
      studentFirstName: map['studentFirstName'] ?? '',
      studentLastName: map['studentLastName'] ?? '',
      studentName: map['studentName'] ?? '',
      studentId: map['studentId'] ?? '',
      studentEmail: map['schoolEmail'],
      score: (map['score'] ?? 0).toDouble(),
      maxScore: (map['maxScore'] ?? 0).toDouble(),
      percentage: (map['percentage'] ?? 0).toDouble(),
      aiConfidence: (map['aiConfidence'] ?? 0).toDouble(),
      status:  () {
        final status = map['status'] ?? 'graded';

        switch (status) {
          case 'graded':
            return GradingStatus.aiSuggested;

          case 'aiSuggested':
            return GradingStatus.aiSuggested;

          case 'pending':
            return GradingStatus.pending;

          case 'flagged':
            return GradingStatus.flagged;

          case 'reviewed':
            return GradingStatus.reviewed;

          default:
            return GradingStatus.pending;
        }
      }(),
      feedback: map['feedback'] ?? '',
      gradingMethod: map['gradingMethod'] ?? 'ai',
      questionResults: ((map['questionResults'] ?? []) as List)
          .map((e) => QuestionResultModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      answers: ((map['answers'] ?? []) as List)
          .map((e) => StudentAnswerModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      submittedAt: DateTime.tryParse(map['submittedAt'] ?? '') ?? DateTime.now(),
      gradedAt: DateTime.tryParse(map['gradedAt'] ?? '') ?? DateTime.now(),
      formId: map['formId'] ?? '',
    );
  }
}