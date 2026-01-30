
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
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

  // Mock filters
  final List<String> _quizzes = const [
    'All Quizzes',
    'Week 3 – Data Structures',
    'Unit 2 – Algorithms',
  ];
  final List<String> _classes = const [
    'All Classes',
    'CSE 101 – A',
    'CSE 101 – B',
  ];

  String _selectedQuiz = 'All Quizzes';
  String _selectedClass = 'All Classes';

  // Mock stats (you can compute these from results list later)
  int totalStudents = 32;
  int avgScore = 78;
  int aiAccuracy = 93;
  int manualOverrides = 2;

  // Mock results data
  final List<_ResultRow> _results = [
    _ResultRow(
      student: 'Jane Doe',
      className: 'CSE 101 – A',
      score: 89,
      status: 'Graded',
      aiConfidence: 95,
    ),
    _ResultRow(
      student: 'Michael Lee',
      className: 'CSE 101 – A',
      score: 61,
      status: 'Graded',
      aiConfidence: 88,
    ),
    _ResultRow(
      student: 'Sofia Torres',
      className: 'CSE 101 – B',
      score: 92,
      status: 'Graded',
      aiConfidence: 97,
    ),
    _ResultRow(
      student: 'David Smith',
      className: 'CSE 101 – B',
      score: 48,
      status: 'Needs Review',
      aiConfidence: 62,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStatsGrid(constraints.maxWidth),
              const SizedBox(height: 16),
              _buildResultsCard(),
            ],
          ),
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
          style: TextStyle(
            fontSize: 13,
            color: _sub,
          ),
        ),
      ],
    );
  }

  // ---------- Stats ----------

  Widget _buildStatsGrid(double maxWidth) {
    // Use a simple Wrap to behave like CSS grid auto-fit
    return Row(
      children: [
        Expanded(child: _statCard(label: 'Total Students', value: '$totalStudents')),
        SizedBox(width: 12),
        Expanded(child: _statCard(label: 'Average Score', value: '$avgScore%')),
        SizedBox(width: 12),
        Expanded(child: _statCard(label: 'AI Accuracy', value: '$aiAccuracy%')),
        SizedBox(width: 12),
        Expanded(child: _statCard(label: 'Manual Overrides', value: '$manualOverrides'))
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
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: _sub),
            ),
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
            items: _quizzes,
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
            items: _classes,
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
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _sub),
          ),
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
    final filtered = _results.where((r) {
      final quizOk = true; // hook your quiz filter here if needed
      final classOk = _selectedClass == 'All Classes' ||
          r.className == _selectedClass;
      return quizOk && classOk;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor:
              WidgetStateProperty.all(const Color(0xFFF9FAFB)),
              columnSpacing: 32,
              columns: const [
                DataColumn(label: Text('Student')),
                DataColumn(label: Text('Class')),
                DataColumn(label: Text('Score')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('AI Confidence')),
                DataColumn(label: Text('Actions')),
              ],
              rows: filtered.map(_buildDataRow).toList(),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(_ResultRow row) {
    final bool isGood = row.score >= 75;
    final TextStyle scoreStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: isGood ? _green : _red,
    );

    final String actionLabel =
    row.status == 'Needs Review' ? 'Review' : 'Override';

    return DataRow(
      cells: [
        DataCell(Text(row.student)),
        DataCell(Text(row.className)),
        DataCell(Text('${row.score}%', style: scoreStyle)),
        DataCell(Text(row.status)),
        DataCell(Text('${row.aiConfidence}%')),
        DataCell(
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              side: const BorderSide(color: _border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _onRowAction(row),
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reviewing ${row.student}...')),
      );
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
