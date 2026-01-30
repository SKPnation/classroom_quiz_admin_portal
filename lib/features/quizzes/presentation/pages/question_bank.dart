import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:flutter/material.dart';

class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  // ---- Design tokens ----
  static const _bg = Color(0xFFF3F4F6);
  static const _card = Colors.white;
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _purple = Color(0xFF6366F1);
  static const _chipsBg = Color(0xFFF3F4FF);
  static const _radius = 16.0;

  // ---- Filters ----
  final _quizOptions = const ['All Quizzes', 'Unit 1 – Intro', 'Unit 2 – Algebra'];
  final _classOptions = const ['All Classes', 'CSE 101 – A', 'CSE 101 – B'];
  final _typeOptions = const ['All Types', 'MCQ', 'T/F', 'Short answer', 'Essay'];

  String _selectedQuiz = 'All Quizzes';
  String _selectedClass = 'All Classes';
  String _selectedType = 'All Types';
  String _search = '';

  // ---- Fake data ----
  final List<_QuestionRow> _allQuestions = [
    _QuestionRow(
      question: 'What is the capital of France?',
      type: 'MCQ',
      difficulty: 'Easy',
      lastUpdated: '2 days ago',
      tags: ['geography'],
    ),
    _QuestionRow(
      question: 'Solve the equation: 3x - 5 = 10',
      type: 'MCQ',
      difficulty: 'Medium',
      lastUpdated: '3 days ago',
      tags: ['math'],
    ),
    _QuestionRow(
      question: 'What are the main causes of the industrial revolution?',
      type: 'Essay',
      difficulty: 'Hard',
      lastUpdated: '4 days ago',
      tags: ['history'],
    ),
    _QuestionRow(
      question: 'TRUE OR FALSE: The mitochondria is the powerhouse of the cell.',
      type: 'T/F',
      difficulty: 'Easy',
      lastUpdated: '4 days ago',
      tags: const [],
    ),
    _QuestionRow(
      question: 'Briefly describe the water cycle.',
      type: 'Short answer',
      difficulty: 'Medium',
      lastUpdated: '4 days ago',
      tags: ['biology'],
    ),
  ];

  // ---- Stats (derived) ----
  int get totalQuestions => _allQuestions.length;
  int get mcqCount => _allQuestions.where((q) => q.type == 'MCQ').length;
  int get tfCount => _allQuestions.where((q) => q.type == 'T/F').length;
  int get essayCount => _allQuestions.where((q) => q.type == 'Essay').length;
  int get shortAnswerCount =>
      _allQuestions.where((q) => q.type == 'Short answer').length;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Apply filters & search
    final filtered = _allQuestions.where((q) {
      final typeOk = _selectedType == 'All Types' || q.type == _selectedType;
      final searchOk =
          _search.isEmpty || q.question.toLowerCase().contains(_search.toLowerCase());
      // Add class/quiz filters when you actually tie questions to those
      return typeOk && searchOk;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFiltersRow(width),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildTableCard(filtered),
        ],
      ),
    );
  }

  // ---------- Header ----------

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Question Bank',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Manage and reuse questions across all quizzes.',
          style: TextStyle(fontSize: 13, color: _sub),
        ),
      ],
    );
  }

  // ---------- Filters Row ----------

  Widget _buildFiltersRow(double width) {
    final isNarrow = width < 900;

    final filters = <Widget>[
      _filterDropdown(
        value: _selectedQuiz,
        items: _quizOptions,
        onChanged: (v) => setState(() => _selectedQuiz = v ?? _selectedQuiz),
      ),
      _filterDropdown(
        value: _selectedClass,
        items: _classOptions,
        onChanged: (v) => setState(() => _selectedClass = v ?? _selectedClass),
      ),
      _filterDropdown(
        value: _selectedType,
        items: _typeOptions,
        onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
      ),
      // Search field
      Expanded(
        child: SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 18),
              hintText: 'Search questions',
              hintStyle: const TextStyle(fontSize: 13, color: _sub),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) => setState(() => _search = val),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Btn(label: "Add Question", onPressed: _onAddQuestion, width: 135, primary: true),
    ];

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters.take(3).toList(), // dropdowns only
          ),
          const SizedBox(height: 8),
          Row(
            children: filters.sublist(3), // search + button
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: 190, child: filters[0]),
        const SizedBox(width: 8),
        SizedBox(width: 190, child: filters[1]),
        const SizedBox(width: 8),
        SizedBox(width: 170, child: filters[2]),
        const SizedBox(width: 8),
        filters[3],
        filters[4],
        filters[5],
      ],
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      height: 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            style: const TextStyle(fontSize: 13, color: _ink),
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e),
              ),
            )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // ---------- Stats Row ----------

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('Total Questions', totalQuestions.toString())),
        SizedBox(width: 12),
        Expanded(child: _statCard('MCQs', mcqCount.toString())),
        SizedBox(width: 12),
        Expanded(child: _statCard('T/F', tfCount.toString())),
        SizedBox(width: 12),
        Expanded(child: _statCard('Short answer', shortAnswerCount.toString())),
        SizedBox(width: 12),
        Expanded(child: _statCard('Essay', essayCount.toString()))
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return SizedBox(
      width: 200,
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

  // ---------- Table Card ----------

  Widget _buildTableCard(List<_QuestionRow> filtered) {
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
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                columnSpacing: 32,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 64,
                columns: const [
                  DataColumn(label: SizedBox.shrink()), // checkbox column
                  DataColumn(label: Text('Question')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Difficulty')),
                  DataColumn(label: Text('Last Updated')),
                  DataColumn(label: Text('Tags')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filtered.map(_buildDataRow).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildDataRow(_QuestionRow row) {
    return DataRow(
      cells: [
        DataCell(
          Checkbox(
            value: row.selected,
            onChanged: (v) {
              setState(() => row.selected = v ?? false);
            },
          ),
        ),
        DataCell(
          SizedBox(
            width: 260,
            child: Text(
              row.question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(_typeChip(row.type)),
        DataCell(Text(row.difficulty)),
        DataCell(Text(row.lastUpdated)),
        DataCell(_tagsCell(row.tags)),
        DataCell(_actionsCell(row)),
      ],
    );
  }

  Widget _typeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _chipsBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        type,
        style: const TextStyle(fontSize: 11, color: _ink),
      ),
    );
  }

  Widget _tagsCell(List<String> tags) {
    if (tags.isEmpty) return const Text('—', style: TextStyle(color: _sub));
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags
          .map(
            (t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            t,
            style: const TextStyle(fontSize: 11, color: _ink),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _actionsCell(_QuestionRow row) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          tooltip: 'Edit',
          onPressed: () => _onEdit(row),
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 18),
          tooltip: 'Duplicate',
          onPressed: () => _onDuplicate(row),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
          tooltip: 'Delete',
          onPressed: () => _onDelete(row),
        ),
      ],
    );
  }

  // ---------- Actions ----------

  void _onAddQuestion() {
    // TODO: navigate to question editor
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Question tapped')),
    );
  }

  void _onEdit(_QuestionRow row) {
    // TODO: open edit page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit: ${row.question}')),
    );
  }

  void _onDuplicate(_QuestionRow row) {
    setState(() {
      _allQuestions.add(row.copyWith(
        question: '${row.question} (copy)',
        lastUpdated: 'Just now',
      ));
    });
  }

  void _onDelete(_QuestionRow row) {
    setState(() {
      _allQuestions.remove(row);
    });
  }
}

// ---- Simple model for table rows ----

class _QuestionRow {
  final String question;
  final String type;
  final String difficulty;
  final String lastUpdated;
  final List<String> tags;
  bool selected;

  _QuestionRow({
    required this.question,
    required this.type,
    required this.difficulty,
    required this.lastUpdated,
    required this.tags,
    this.selected = false,
  });

  _QuestionRow copyWith({
    String? question,
    String? type,
    String? difficulty,
    String? lastUpdated,
    List<String>? tags,
    bool? selected,
  }) {
    return _QuestionRow(
      question: question ?? this.question,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      tags: tags ?? this.tags,
      selected: selected ?? this.selected,
    );
  }
}
