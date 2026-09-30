import 'package:classroom_quiz_admin_portal/features/grading_insights/data/models/grading_attempt_model.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/data/models/question_result_model.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/presentation/widgets/legend_item.dart';
import 'package:flutter/material.dart';

class ReviewSubmissionPage extends StatefulWidget {
  const ReviewSubmissionPage({
    super.key,
    required this.gradingAttempt,
    this.onBack,
    this.onRegrade,
    this.onSaveDraft,
    this.onApprove,
  });

  final GradingAttemptModel gradingAttempt;

  final VoidCallback? onBack;

  final Future<void> Function(
      GradingAttemptModel gradingAttempt,
      )? onRegrade;

  final Future<void> Function(
      GradingAttemptModel gradingAttempt,
      Map<int, double> scoreOverrides,
      Map<int, String> feedbackOverrides,
      String overallFeedback,
      )? onSaveDraft;

  final Future<void> Function(
      GradingAttemptModel gradingAttempt,
      Map<int, double> scoreOverrides,
      Map<int, String> feedbackOverrides,
      String overallFeedback,
      )? onApprove;

  @override
  State<ReviewSubmissionPage> createState() =>
      _ReviewSubmissionPageState();
}

class _ReviewSubmissionPageState extends State<ReviewSubmissionPage> {
  static const Color _background = Color(0xFFF5F6F8);
  static const Color _card = Colors.white;
  static const Color _ink = Color(0xFF111827);
  static const Color _sub = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _purple = Color(0xFF65239A);
  static const Color _green = Color(0xFF16A34A);
  static const Color _orange = Color(0xFFF59E0B);
  static const Color _red = Color(0xFFDC2626);

  late final TextEditingController overallFeedbackController;

  final Map<int, double> scoreOverrides = {};
  final Map<int, String> feedbackOverrides = {};
  final Map<int, TextEditingController> feedbackControllers = {};

  bool isRegrading = false;
  bool isSaving = false;
  bool isApproving = false;

  int selectedTab = 0;

  GradingAttemptModel get gradingAttempt => widget.gradingAttempt;

  @override
  void initState() {
    super.initState();

    overallFeedbackController = TextEditingController(
      text: gradingAttempt.feedback,
    );

    for (
    var index = 0;
    index < gradingAttempt.questionResults.length;
    index++
    ) {
      feedbackControllers[index] = TextEditingController(
        text: gradingAttempt.questionResults[index].feedback,
      );
    }
  }

  @override
  void dispose() {
    overallFeedbackController.dispose();

    for (final controller in feedbackControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  double get originalScore {
    return gradingAttempt.questionResults.fold<double>(
      0,
          (sum, question) => sum + question.earnedPoints,
    );
  }

  double get adjustedScore {
    double total = 0;

    for (var index = 0;
    index < gradingAttempt.questionResults.length;
    index++) {
      final question = gradingAttempt.questionResults[index];

      total += scoreOverrides[index] ?? question.earnedPoints;
    }

    return total;
  }

  double get maximumScore {
    return gradingAttempt.questionResults.fold<double>(
      0,
          (sum, question) => sum + question.maxPoints,
    );
  }

  int get changedQuestionCount {
    var count = 0;

    for (var index = 0;
    index < gradingAttempt.questionResults.length;
    index++) {
      final originalScore =
          gradingAttempt.questionResults[index].earnedPoints;

      final overriddenScore = scoreOverrides[index];

      if (overriddenScore != null &&
          overriddenScore != originalScore) {
        count++;
      }
    }

    return count;
  }

  double get adjustedPercentage {
    if (maximumScore == 0) return 0;

    return (adjustedScore / maximumScore) * 100;
  }

  double selectedScoreFor(int index) {
    return scoreOverrides[index] ??
        gradingAttempt.questionResults[index].earnedPoints;
  }

  String feedbackFor(int index) {
    return feedbackOverrides[index] ??
        gradingAttempt.questionResults[index].feedback;
  }

  void updateScore({
    required int index,
    required double score,
  }) {
    final question = gradingAttempt.questionResults[index];

    final safeScore = score.clamp(
      0,
      question.maxPoints,
    ).toDouble();

    setState(() {
      scoreOverrides[index] = safeScore;
    });
  }

  void updateFeedback({
    required int index,
    required String feedback,
  }) {
    setState(() {
      feedbackOverrides[index] = feedback;
      feedbackControllers[index]?.text = feedback;
    });
  }

  void resetQuestion(int index) {
    setState(() {
      scoreOverrides.remove(index);
      feedbackOverrides.remove(index);

      feedbackControllers[index]?.text =
          gradingAttempt.questionResults[index].feedback;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 24),

                  _buildSubmissionSummary(),
                  const SizedBox(height: 24),

                  Container(
                    decoration: _cardDecoration(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            18,
                            20,
                            0,
                          ),
                          child: Row(
                            children: [
                              _tabButton(
                                index: 0,
                                label: 'Review Answers',
                              ),
                              // const SizedBox(width: 24),
                              // _tabButton(
                              //   index: 1,
                              //   label: 'Submission Details',
                              // ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: selectedTab == 0
                                ? Column(
                              key: const ValueKey('answers'),
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                _confidenceLegend(),
                                const SizedBox(height: 20),
                                _buildQuestions(),
                              ],
                            )
                                : Column(
                              key: const ValueKey('details'),
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                _buildSubmissionDetails(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //
                  // const SizedBox(height: 24),
                  //
                  // Container(
                  //   decoration: _cardDecoration(),
                  //   padding: const EdgeInsets.all(24),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       const Text(
                  //         'Overall Feedback',
                  //         style: TextStyle(
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w700,
                  //           color: _ink,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 16),
                  //
                  //       TextField(
                  //         controller: overallFeedbackController,
                  //         minLines: 4,
                  //         maxLines: 8,
                  //         decoration: InputDecoration(
                  //           hintText:
                  //           'Provide feedback for this submission...',
                  //           border: OutlineInputBorder(
                  //             borderRadius:
                  //             BorderRadius.circular(8),
                  //           ),
                  //         ),
                  //       ),
                  //
                  //       const SizedBox(height: 24),
                  //
                  //       Row(
                  //         children: [
                  //           Expanded(
                  //             child: Text(
                  //               'Original Score: '
                  //                   '${_formatScore(originalScore)} / '
                  //                   '${_formatScore(maximumScore)}\n'
                  //                   'Adjusted Score: '
                  //                   '${_formatScore(adjustedScore)} / '
                  //                   '${_formatScore(maximumScore)} '
                  //                   '(${adjustedPercentage.toStringAsFixed(1)}%)\n'
                  //                   'Modified Questions: '
                  //                   '$changedQuestionCount',
                  //               style: const TextStyle(
                  //                 color: _sub,
                  //                 height: 1.6,
                  //               ),
                  //             ),
                  //           ),
                  //
                  //           const SizedBox(width: 20),
                  //
                  //           OutlinedButton(
                  //             onPressed:
                  //             isSaving ? null : saveDraft,
                  //             child: isSaving
                  //                 ? const SizedBox(
                  //               width: 18,
                  //               height: 18,
                  //               child:
                  //               CircularProgressIndicator(
                  //                 strokeWidth: 2,
                  //               ),
                  //             )
                  //                 : const Text('Save Draft'),
                  //           ),
                  //
                  //           const SizedBox(width: 12),
                  //
                  //           ElevatedButton.icon(
                  //             onPressed: isApproving
                  //                 ? null
                  //                 : approveFinalGrade,
                  //             style: ElevatedButton.styleFrom(
                  //               backgroundColor: _purple,
                  //               foregroundColor: Colors.white,
                  //             ),
                  //             icon: isApproving
                  //                 ? const SizedBox(
                  //               width: 18,
                  //               height: 18,
                  //               child:
                  //               CircularProgressIndicator(
                  //                 strokeWidth: 2,
                  //                 color: Colors.white,
                  //               ),
                  //             )
                  //                 : const Icon(Icons.check),
                  //             label: Text(
                  //               isApproving
                  //                   ? 'Approving...'
                  //                   : 'Approve Final Grade',
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryItem(
          label: 'Student',
          value: gradingAttempt.studentName,
        ),
        const SizedBox(height: 16),
        _summaryItem(
          label: 'Student ID',
          value: gradingAttempt.studentId,
        ),
        const SizedBox(height: 16),
        _summaryItem(
          label: 'Email',
          value: gradingAttempt.studentEmail ?? '-',
        ),
        const SizedBox(height: 16),
        _summaryItem(
          label: 'Quiz',
          value: gradingAttempt.quizTitle,
        ),
        const SizedBox(height: 16),
        _summaryItem(
          label: 'Grading Method',
          value: gradingAttempt.gradingMethod,
        ),
        const SizedBox(height: 16),
        _summaryItem(
          label: 'Status',
          value: gradingAttempt.status.name,
        ),
        const SizedBox(height: 16),
        _summaryItem(
          label: 'Submitted',
          value: _formatDateTime(gradingAttempt.submittedAt),
        ),
        const SizedBox(height: 16),
        _summaryItem(
          label: 'Graded',
          value: _formatDateTime(gradingAttempt.gradedAt),
        ),
      ],
    );
  }

  Widget _buildQuestions() {
    final questions = gradingAttempt.questionResults;

    if (questions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: _cardDecoration(),
        child: const Center(
          child: Text(
            'No question results are available for this submission.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _sub,
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        questions.length,
            (index) {
          final question = questions[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == questions.length - 1 ? 0 : 14,
            ),
            child: buildQuestionCard(
              question: question,
              index: index,
              selectedScore: selectedScoreFor(index),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: _border,
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(12, 0, 0, 0),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Widget buildQuestionCard({
    required QuestionResultModel question,
    required int index,
    required double selectedScore,
  }) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor:
                  question.isCorrect ? _green : _orange,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1} '
                            '(${_formatScore(question.maxPoints)} points)',
                        style: const TextStyle(
                          color: _sub,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        question.question,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 850) {
                return _buildCompactQuestionBody(
                  question: question,
                  index: index,
                  selectedScore: selectedScore,
                );
              }

              return _buildWideQuestionBody(
                question: question,
                index: index,
                selectedScore: selectedScore,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactQuestionBody({
    required QuestionResultModel question,
    required int index,
    required double selectedScore,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Answer',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _sub,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            question.studentAnswer.trim().isEmpty
                ? 'No answer provided'
                : question.studentAnswer,
            style: const TextStyle(
              fontSize: 13,
              color: _ink,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'AI Feedback',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _sub,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feedbackFor(index),
            style: const TextStyle(
              fontSize: 13,
              color: _ink,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Text(
                'Score:',
                style: const TextStyle(
                  fontSize: 12,
                  color: _sub,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_formatScore(selectedScore)} / ${_formatScore(question.maxPoints)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: question.isCorrect ? _green : _orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildQuestionActions(
            question: question,
            index: index,
            selectedScore: selectedScore,
          ),
        ],
      ),
    );
  }

  Widget _buildWideQuestionBody({
    required QuestionResultModel question,
    required int index,
    required double selectedScore,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: _questionSection(
              title: 'Student Answer',
              child: SelectableText(
                question.studentAnswer.trim().isEmpty
                    ? 'No answer provided'
                    : question.studentAnswer,
                style: const TextStyle(
                  fontSize: 13,
                  color: _ink,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: _border,
          ),
          Expanded(
            child: _questionSection(
              title: 'AI Score',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatScore(question.earnedPoints)} / '
                        '${_formatScore(question.maxPoints)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: question.isCorrect ? _green : _orange,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    question.isCorrect ? 'Correct' : 'Needs review',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: question.isCorrect ? _green : _orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: _border,
          ),
          Expanded(
            flex: 2,
            child: _questionSection(
              title: 'AI Feedback',
              child: Text(
                feedbackFor(index).trim().isEmpty
                    ? 'No feedback provided'
                    : feedbackFor(index),
                style: const TextStyle(
                  fontSize: 13,
                  color: _ink,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: _border,
          ),
          SizedBox(
            width: 210,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildQuestionActions(
                question: question,
                index: index,
                selectedScore: selectedScore,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionSection({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _sub,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[dateTime.month - 1];

    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$month ${dateTime.day}, ${dateTime.year} • '
        '$hour:$minute $period';
  }

  String _formatScore(double score) {
    return score == score.roundToDouble()
        ? score.toInt().toString()
        : score.toStringAsFixed(1);
  }

  Widget _buildTopBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 800;

        final titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _sub,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back to Grading Queue'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Review Submission',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Review AI-suggested scores, provide feedback, and approve the final grade.',
              style: TextStyle(
                fontSize: 13,
                color: _sub,
              ),
            ),
          ],
        );

        // final actions = Wrap(
        //   spacing: 12,
        //   runSpacing: 12,
        //   children: [
        //     OutlinedButton.icon(
        //       onPressed: isRegrading ? null : regradeWithAi,
        //       style: OutlinedButton.styleFrom(
        //         foregroundColor: _ink,
        //         side: const BorderSide(color: _border),
        //         backgroundColor: Colors.white,
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 18,
        //           vertical: 16,
        //         ),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //       ),
        //       icon: isRegrading
        //           ? const SizedBox(
        //         width: 17,
        //         height: 17,
        //         child: CircularProgressIndicator(strokeWidth: 2),
        //       )
        //           : const Icon(Icons.refresh, size: 18),
        //       label: Text(
        //         isRegrading ? 'Regrading...' : 'Regrade with AI',
        //       ),
        //     ),
        //     ElevatedButton.icon(
        //       onPressed: isApproving ? null : approveFinalGrade,
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: _purple,
        //         foregroundColor: Colors.white,
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 20,
        //           vertical: 16,
        //         ),
        //         elevation: 0,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //       ),
        //       icon: isApproving
        //           ? const SizedBox(
        //         width: 17,
        //         height: 17,
        //         child: CircularProgressIndicator(
        //           strokeWidth: 2,
        //           color: Colors.white,
        //         ),
        //       )
        //           : const Icon(Icons.check, size: 18),
        //       label: Text(
        //         isApproving ? 'Approving...' : 'Approve Final Grade',
        //       ),
        //     ),
        //   ],
        // );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleSection,
              const SizedBox(height: 18),
              // actions,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleSection),
            // actions,
          ],
        );
      },
    );
  }

  Widget _buildSubmissionSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 850;

          final student = _summaryStudent();

          final details = [
            _summaryItem(
              label: 'Quiz Title',
              value: gradingAttempt.quizTitle.isEmpty
                  ? 'Untitled Quiz'
                  : gradingAttempt.quizTitle,
            ),
            _summaryItem(
              label: 'Grading Method',
              value: gradingAttempt.gradingMethod,
            ),
            _confidenceSummary(),
            _scoreSummaryItem(),
          ];

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                student,
                const SizedBox(height: 20),
                Wrap(
                  spacing: 24,
                  runSpacing: 20,
                  children: details
                      .map(
                        (item) => SizedBox(
                      width: 180,
                      child: item,
                    ),
                  )
                      .toList(),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 2, child: student),
              ...details.map(
                    (item) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: _border),
                      ),
                    ),
                    child: item,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _confidenceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Confidence',
          style: TextStyle(
            fontSize: 11,
            color: _sub,
          ),
        ),
        const SizedBox(height: 8),
        _confidenceChip(gradingAttempt.aiConfidence),
      ],
    );
  }

  Widget _confidenceChip(double confidence) {
    final normalized = confidence > 1
        ? confidence / 100
        : confidence;

    final percentage = (normalized * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _confidenceBackground(normalized),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: _confidenceColor(normalized),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 0.9) return _green;
    if (confidence >= 0.7) return _orange;
    return _red;
  }

  Color _confidenceBackground(double confidence) {
    if (confidence >= 0.9) {
      return const Color(0xFFDCFCE7);
    }

    if (confidence >= 0.7) {
      return const Color(0xFFFEF3C7);
    }

    return const Color(0xFFFEE2E2);
  }

  Future<void> saveDraft() async {
    if (widget.onSaveDraft == null || isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      await widget.onSaveDraft!(
        gradingAttempt,
        Map<int, double>.from(scoreOverrides),
        Map<int, String>.from(feedbackOverrides),
        overallFeedbackController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> approveGrade() async {
    if (widget.onApprove == null || isApproving) return;

    setState(() {
      isApproving = true;
    });

    try {
      await widget.onApprove!(
        gradingAttempt,
        Map<int, double>.from(scoreOverrides),
        Map<int, String>.from(feedbackOverrides),
        overallFeedbackController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() {
          isApproving = false;
        });
      }
    }
  }

  Future<void> regradeWithAi() async {
    if (widget.onRegrade == null || isRegrading) return;

    setState(() {
      isRegrading = true;
    });

    try {
      await widget.onRegrade!(gradingAttempt);
    } finally {
      if (mounted) {
        setState(() {
          isRegrading = false;
        });
      }
    }
  }

  Future<void> approveFinalGrade() async {
    if (widget.onApprove == null || isApproving) return;

    setState(() => isApproving = true);

    try {
      await widget.onApprove!(
        gradingAttempt,
        Map<int, double>.from(scoreOverrides),
        Map<int, String>.from(feedbackOverrides),
        overallFeedbackController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() => isApproving = false);
      }
    }
  }

  Widget _summaryStudent() {
    final email = gradingAttempt.studentEmail?.trim() ?? '';

    final displayName = gradingAttempt.studentName.trim().isNotEmpty
        ? gradingAttempt.studentName.trim()
        : email.isNotEmpty
        ? email
        : 'Unknown student';

    final initial = displayName.isEmpty
        ? '?'
        : displayName[0].toUpperCase();

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFEDE9FE),
          child: Text(
            initial,
            style: const TextStyle(
              color: _purple,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 15,
                    color: _sub,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      email.isEmpty ? 'No email provided' : email,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _sub,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: _sub,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Submitted: '
                          '${_formatDateTime(gradingAttempt.submittedAt)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _sub,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _sub,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: _ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _scoreSummaryItem() {
    final percentage = maximumScore == 0
        ? 0
        : ((adjustedScore / maximumScore) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overall Score',
          style: TextStyle(
            fontSize: 11,
            color: _sub,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$adjustedScore / $maximumScore',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontSize: 12,
            color: _sub,
          ),
        ),
      ],
    );
  }


  Widget _tabButton({
    required int index,
    required String label,
  }) {
    final selected = selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? _purple : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _purple : _sub,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _confidenceLegend() {
    return const Row(
      children: [
        LegendItem(
          color: Color(0xFF22C55E),
          label: 'High (≥90%)',
        ),
        SizedBox(width: 18),
        LegendItem(
          color: Color(0xFFF59E0B),
          label: 'Medium (70–89%)',
        ),
        SizedBox(width: 18),
        LegendItem(
          color: Color(0xFFEF4444),
          label: 'Low (<70%)',
        ),
      ],
    );
  }

  Widget buildCompactQuestionBody({
    required QuestionResultModel question,
    required int index,
    required double selectedScore,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Answer',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _sub,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            question.studentAnswer.trim().isEmpty
                ? 'No answer provided'
                : question.studentAnswer,
            style: const TextStyle(
              fontSize: 13,
              color: _ink,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'AI Feedback',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _sub,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feedbackFor(index),
            style: const TextStyle(
              fontSize: 13,
              color: _ink,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Text(
                'Score:',
                style: const TextStyle(
                  fontSize: 12,
                  color: _sub,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_formatScore(selectedScore)} / ${_formatScore(question.maxPoints)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: question.isCorrect ? _green : _orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildQuestionActions(
            question: question,
            index: index,
            selectedScore: selectedScore,
          ),
        ],
      ),
    );
  }


  Widget _buildQuestionActions({
    required QuestionResultModel question,
    required int index,
    required double selectedScore,
  }) {
    final maxScore = question.maxPoints.floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Override Score',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _sub,
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            maxScore + 1,
                (score) {
              final value = score.toDouble();
              final selected = selectedScore == value;

              return InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  updateScore(
                    index: index,
                    score: value,
                  );
                },
                child: Container(
                  width: 34,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? _purple : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selected ? _purple : _border,
                    ),
                  ),
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : _ink,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // SizedBox(
        //   width: double.infinity,
        //   child: OutlinedButton.icon(
        //     onPressed: () => _editFeedback(
        //       index: index,
        //       question: question,
        //     ),
        //     icon: const Icon(
        //       Icons.edit_outlined,
        //       size: 16,
        //     ),
        //     label: const Text('Edit Feedback'),
        //   ),
        // ),
        //
        // const SizedBox(height: 8),
        //
        // SizedBox(
        //   width: double.infinity,
        //   child: TextButton.icon(
        //     onPressed: () {
        //       resetQuestion(index);
        //     },
        //     icon: const Icon(
        //       Icons.restart_alt,
        //       size: 16,
        //     ),
        //     label: const Text('Reset to AI Grade'),
        //   ),
        // ),
      ],
    );
  }

  Future<void> _editFeedback({
    required int index,
    required QuestionResultModel question,
  }) async {
    final controller = TextEditingController(
      text: feedbackFor(index),
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Feedback'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: controller,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    updateFeedback(
      index: index,
      feedback: result,
    );
  }

}

