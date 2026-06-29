import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/grading_insights/presentation/controllers/grading_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final controller = GradingInsightsController.instance;

  // Colors from the HTML design
  static const _bg = Color(0xFFF6F7FB);
  static const _card = Colors.white;
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _purple = AppColors.purple;
  static const _green = Color(0xFF22C55E);
  static const _red = Color(0xFFDC2626);
  static const _radius = 14.0;

  String _selectedQuiz = 'All Quizzes';
  String _selectedClass = 'All Classes';

  @override
  void initState() {
    controller.loadGradingInsights();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Obx(()=>Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStatsGrid(controller),
              const SizedBox(height: 16),
              _buildResultsCard(),
            ],
          )),
        );
      },
    );
  }

  // ---------- Header ----------

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Quiz Results',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'View AI-graded results, performance, and make manual score adjustments if necessary.',
          style: TextStyle(fontSize: 13, color: _sub),
        ),
      ],
    );
  }

  // ---------- Stats ----------

  Widget _buildStatsGrid(GradingInsightsController controller) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: 'Total Students',
            value: '${controller.totalStudents}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: 'Average Score',
            value: '${controller.averageScore.toStringAsFixed(0)}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: 'AI Accuracy',
            value:
            '${(controller.averageAiConfidence * 100).toStringAsFixed(0)}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: 'Manual Overrides',
            value: '${controller.manualOverrides}',
          ),
        ),
      ],
    );
  }

  Widget _statCard({required String label, required String value}) {
    return SizedBox(
      width: 260,
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              offset: Offset(0, 1),
              color: Color.fromARGB(10, 0, 0, 0),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: _sub)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Results Card ----------

  Widget _buildResultsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            offset: Offset(0, 1),
            color: Color.fromARGB(10, 0, 0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFiltersRow(),
          const SizedBox(height: 16),
          _buildResultsTable(),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    final quizzes = [
      'All Quizzes',
      ...controller.results.map((e) => e.quizTitle).toSet().toList(),
    ];
    final classes = [
      'All Classes',
      ...controller.results
          .map(
            (e) => e.quizTitle,
          ) // Assuming quizTitle represents class for demo
          .toSet()
          .toList(),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220,
          child: _dropdown(
            label: null,
            value: _selectedQuiz,
            items: quizzes,
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _selectedQuiz = val;
                // TODO: filter results based on quiz
              });
            },
          ),
        ),
        SizedBox(
          width: 180,
          child: _dropdown(
            label: null,
            value: _selectedClass,
            items: classes,
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _selectedClass = val;
                // TODO: filter results based on class
              });
            },
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _exportCsv,
          child: const Text(
            'Export CSV',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: const TextStyle(fontSize: 12, color: _sub)),
          const SizedBox(height: 4),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsTable() {
    // Basic filtering (optional)
    final filtered = controller.results.where((attempt) {
      final classOk = _selectedClass == 'All Classes';
          // || attempt.className == _selectedClass;

      final quizOk = _selectedQuiz == 'All Quizzes'
          || attempt.quizTitle == _selectedQuiz;

      return classOk && quizOk;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
              columnSpacing: 32,
              columns: const [
                DataColumn(label: Text('School Email')),
                DataColumn(label: Text('Quiz')),
                DataColumn(label: Text('Score')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('AI Confidence')),
                DataColumn(label: Text('Actions')),
              ],
              rows: filtered.map((attempt) {
                return DataRow(
                  cells: [
                    DataCell(Text(attempt.studentEmail ?? 'N/A')),
                    DataCell(Text(attempt.quizTitle)),
                    DataCell(Text('${attempt.percentage.toStringAsFixed(0)}%')),
                    DataCell(Text(attempt.status.name)),
                    DataCell(
                      Text(
                        '${(attempt.aiConfidence * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                    DataCell(
                      OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          attempt.status == 'needs_review'
                              ? 'Review'
                              : 'Override',
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // DataRow _buildDataRow(_ResultRow row) {
  //   final bool isGood = row.score >= 75;
  //   final TextStyle scoreStyle = TextStyle(
  //     fontWeight: FontWeight.w600,
  //     color: isGood ? _green : _red,
  //   );
  //
  //   final String actionLabel = row.status == 'Needs Review'
  //       ? 'Review'
  //       : 'Override';
  //
  //   return DataRow(
  //     cells: [
  //       DataCell(Text(row.student)),
  //       DataCell(Text(row.className)),
  //       DataCell(Text('${row.score}%', style: scoreStyle)),
  //       DataCell(Text(row.status)),
  //       DataCell(Text('${row.aiConfidence}%')),
  //       DataCell(
  //         OutlinedButton(
  //           style: OutlinedButton.styleFrom(
  //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  //             side: const BorderSide(color: _border),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           onPressed: () => _onRowAction(row),
  //           child: Text(
  //             actionLabel,
  //             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void _exportCsv() {
    // Replace with real export logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting results to CSV...')),
    );
  }

  void _onRowAction(_ResultRow row) {
    // You can navigate to a detailed view or open a dialog here
    if (row.status == 'Needs Review') {
      // open review flow
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reviewing ${row.student}...')));
    } else {
      // open override flow
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Overriding score for ${row.student}...')),
      );
    }
  }
}

// ---------- Data model ----------

class _ResultRow {
  final String student;
  final String className;
  final int score;
  final String status;
  final int aiConfidence;

  _ResultRow({
    required this.student,
    required this.className,
    required this.score,
    required this.status,
    required this.aiConfidence,
  });
}
