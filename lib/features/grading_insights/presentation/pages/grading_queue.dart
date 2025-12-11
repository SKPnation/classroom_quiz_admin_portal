import 'package:flutter/material.dart';

class GradingQueuePage extends StatefulWidget {
  const GradingQueuePage({super.key});

  @override
  State<GradingQueuePage> createState() => _GradingQueuePageState();
}

class _GradingQueuePageState extends State<GradingQueuePage> {
  // ---- Design tokens ----
  static const _bg = Color(0xFFF3F4F6);
  static const _card = Colors.white;
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _purple = Color(0xFF6366F1);
  static const _radius = 16.0;

  // ---- Filters ----
  final _quizOptions = const [
    'All Quizzes',
    'Week 1 Check-in',
    'Midterm Exam',
    'Reading Comprehension',
  ];
  final _statusOptions = const [
    'All Statuses',
    'Pending',
    'AI Suggested',
    'Flagged',
    'Reviewed',
  ];

  String _selectedQuiz = 'All Quizzes';
  String _selectedStatus = 'All Statuses';

  // ---- Fake data ----
  final List<_GradingRow> _allRows = [
    _GradingRow(
      student: 'Jane Doe',
      className: 'CSE 101 – A',
      questionLabel: 'Q3 – Short Answer',
      aiSuggestion: 'Score: 3/5 (partial)',
      status: GradingStatus.pending,
    ),
    _GradingRow(
      student: 'Michael Lee',
      className: 'CSE 101 – A',
      questionLabel: 'Q5 – Essay',
      aiSuggestion: 'Score: 8/10',
      status: GradingStatus.aiSuggested,
    ),
    _GradingRow(
      student: 'Sofia Torres',
      className: 'ENG 201',
      questionLabel: 'Q2 – Open Response',
      aiSuggestion: 'Flagged: off-topic',
      status: GradingStatus.flagged,
    ),
    _GradingRow(
      student: 'David Smith',
      className: 'SCI 240',
      questionLabel: 'Q7 – Explanation',
      aiSuggestion: 'Score: 5/5',
      status: GradingStatus.reviewed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filtered list
    final filtered = _allRows.where((row) {
      final quizOk = true; // plug into real quiz mapping later if needed
      final statusOk = _selectedStatus == 'All Statuses'
          ? true
          : _statusLabel(row.status) == _selectedStatus;
      return quizOk && statusOk;
    }).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildStatsRow(),
                const SizedBox(height: 16),
                _buildTableCard(filtered),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grading Queue',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Review AI-suggested scores, flagged answers, and pending grading.',
          style: TextStyle(fontSize: 13, color: _sub),
        ),
      ],
    );
  }

  // ---------- Stats row ----------

  Widget _buildStatsRow() {
    final pending =
        _allRows.where((r) => r.status == GradingStatus.pending).length;
    final flagged =
        _allRows.where((r) => r.status == GradingStatus.flagged).length;
    final aiSuggested =
        _allRows.where((r) => r.status == GradingStatus.aiSuggested).length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _statCard('Pending items', pending.toString()),
        _statCard('AI flagged', flagged.toString()),
        _statCard('AI suggested', aiSuggested.toString()),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return SizedBox(
      width: 220,
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              offset: Offset(0, 1),
              color: Color.fromARGB(12, 0, 0, 0),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: _sub)),
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

  // ---------- Table card ----------

  Widget _buildTableCard(List<_GradingRow> rows) {
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
            color: Color.fromARGB(12, 0, 0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableFiltersRow(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints:
                  BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xFFF9FAFB),
                    ),
                    columnSpacing: 32,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 64,
                    columns: const [
                      DataColumn(label: Text('Student')),
                      DataColumn(label: Text('Class')),
                      DataColumn(label: Text('Question')),
                      DataColumn(label: Text('AI Suggestion')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: rows.map(_buildDataRow).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Filters (quiz + status) above table
  Widget _buildTableFiltersRow() {
    return Row(
      children: [
        SizedBox(
          width: 230,
          height: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedQuiz,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                style: const TextStyle(fontSize: 13, color: _ink),
                items: _quizOptions
                    .map(
                      (q) => DropdownMenuItem<String>(
                    value: q,
                    child: Text(q),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => _selectedQuiz = val);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 180,
          height: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                style: const TextStyle(fontSize: 13, color: _ink),
                items: _statusOptions
                    .map(
                      (s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(s),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => _selectedStatus = val);
                },
              ),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 40,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _purple),
              foregroundColor: _purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            icon: const Icon(Icons.checklist_rounded, size: 18),
            label: const Text(
              'Bulk Review',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            onPressed: _onBulkReview,
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(_GradingRow row) {
    return DataRow(
      cells: [
        DataCell(Text(row.student)),
        DataCell(Text(row.className)),
        DataCell(Text(row.questionLabel)),
        DataCell(Text(row.aiSuggestion)),
        DataCell(_statusChip(row.status)),
        DataCell(_actionsButton(row)),
      ],
    );
  }

  // ---------- Status chip ----------

  Widget _statusChip(GradingStatus status) {
    final label = _statusLabel(status);

    Color color;
    Color bg;

    switch (status) {
      case GradingStatus.pending:
        color = const Color(0xFFDC2626); // red
        bg = const Color(0xFFFEE2E2);
        break;
      case GradingStatus.aiSuggested:
        color = _purple;
        bg = const Color(0xFFEEF2FF);
        break;
      case GradingStatus.flagged:
        color = const Color(0xFFF97316); // orange
        bg = const Color(0xFFFFEDD5);
        break;
      case GradingStatus.reviewed:
        color = const Color(0xFF16A34A); // green
        bg = const Color(0xFFD1FAE5);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _statusLabel(GradingStatus status) {
    switch (status) {
      case GradingStatus.pending:
        return 'Pending';
      case GradingStatus.aiSuggested:
        return 'AI Suggested';
      case GradingStatus.flagged:
        return 'Flagged';
      case GradingStatus.reviewed:
        return 'Reviewed';
    }
  }

  // ---------- Row actions ----------

  Widget _actionsButton(_GradingRow row) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        onPressed: () => _onReviewRow(row),
        child: const Text(
          'Review',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ---------- Actions ----------

  void _onReviewRow(_GradingRow row) {
    // TODO: navigate to detailed grading screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reviewing: ${row.student} – ${row.questionLabel}')),
    );
  }

  void _onBulkReview() {
    // TODO: open bulk review flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bulk Review clicked')),
    );
  }
}

// ---------- Model ----------

enum GradingStatus { pending, aiSuggested, flagged, reviewed }

class _GradingRow {
  final String student;
  final String className;
  final String questionLabel;
  final String aiSuggestion;
  final GradingStatus status;

  _GradingRow({
    required this.student,
    required this.className,
    required this.questionLabel,
    required this.aiSuggestion,
    required this.status,
  });
}
